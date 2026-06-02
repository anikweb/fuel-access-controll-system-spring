package com.invisible.facs.controller;

import com.invisible.facs.model.Station;
import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import com.invisible.facs.model.User;
import com.invisible.facs.model.UserProfile;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.TransactionRepository;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.repository.VehicleRepository;
import com.invisible.facs.service.FileStorageService;
import com.invisible.facs.service.PlateOcrService;
import com.invisible.facs.util.BanglaDateTime;
import com.invisible.facs.util.BanglaDigits;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.Principal;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/operator")
@RequiredArgsConstructor
public class OperatorController {

    private static final SecureRandom TXN_CODE_RNG = new SecureRandom();
    private static final int TRANSACTIONS_PAGE_SIZE = 15;

    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;
    private final VehicleRepository vehicleRepository;
    private final FileStorageService fileStorageService;
    private final PlateOcrService plateOcrService;

    @ModelAttribute
    @Transactional(readOnly = true)
    public void populateOperatorContext(Principal principal, Model model) {
        if (principal == null) return;
        Optional<User> userOpt = userRepository.findByMobile(principal.getName());
        if (userOpt.isEmpty()) return;
        User operator = userOpt.get();

        Map<String, Object> operatorCard = new HashMap<>();
        operatorCard.put("name", emptyToDash(operator.getName()));
        operatorCard.put("displayId", "#" + BanglaDigits.convert(String.valueOf(operator.getId())));
        operatorCard.put("photoUrl", operator.getPhotoPath());
        model.addAttribute("operator", operatorCard);

        Station station = operator.getStation();
        if (station != null) {
            Map<String, Object> stationCard = new HashMap<>();
            stationCard.put("name", station.getName());
            stationCard.put("location", station.getLocation());
            model.addAttribute("station", stationCard);
        }
    }

    @GetMapping({"", "/", "/dashboard"})
    @Transactional(readOnly = true)
    public String dashboard(Principal principal, Model model) {
        if (principal == null) return "redirect:/";

        Optional<User> userOpt = userRepository.findByMobile(principal.getName());
        if (userOpt.isEmpty()) return "redirect:/";
        User operator = userOpt.get();

        long successCount = transactionRepository.countByOperatorIdAndStatus(operator.getId(), TransactionStatus.SUCCESS);
        long rejectedCount = transactionRepository.countByOperatorIdAndStatus(operator.getId(), TransactionStatus.CANCELLED);
        BigDecimal totalLiters = transactionRepository.sumFuelLitersByOperatorIdAndStatus(operator.getId(), TransactionStatus.SUCCESS);
        if (totalLiters == null) totalLiters = BigDecimal.ZERO;

        model.addAttribute("successCount", BanglaDigits.convert(formatThousands(successCount)));
        model.addAttribute("rejectedCount", BanglaDigits.convert(formatThousands(rejectedCount)));
        model.addAttribute("totalLitersDisplay",
                BanglaDigits.convert(formatLitersThousands(totalLiters)) + " লি.");

        List<Transaction> recent = transactionRepository.findTop10ByOperatorIdOrderByCreatedAtDesc(operator.getId());
        List<Map<String, Object>> rows = new ArrayList<>();
        for (Transaction t : recent) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", t.getId());
            row.put("timeOfDay", BanglaDateTime.formatTime(t.getCreatedAt()));
            row.put("dateLine", BanglaDateTime.formatDate(t.getCreatedAt()));
            row.put("vehiclePlate", t.getVehicle() == null ? "—" : t.getVehicle().getPlateNumber());
            row.put("amountDisplay", formatLitersAmount(t.getFuelLiters()));
            row.put("fuelTypeLabel", fuelTypeLabel(t.getFuelType()));
            row.put("fuelTypeBadgeClass", fuelTypeBadgeClass(t.getFuelType()));
            row.put("statusLabel", statusLabel(t.getStatus()));
            row.put("statusIcon", statusIcon(t.getStatus()));
            row.put("statusTone", statusTone(t.getStatus()));
            rows.add(row);
        }
        model.addAttribute("recentTransactions", rows);
        return "operator/dashboard";
    }

    @GetMapping("/transactions")
    @Transactional(readOnly = true)
    public String transactionsList(@RequestParam(name = "q", required = false) String q,
                                   @RequestParam(name = "date", required = false) String date,
                                   @RequestParam(name = "status", required = false) String status,
                                   @RequestParam(name = "fuelType", required = false) String fuelType,
                                   @RequestParam(name = "page", defaultValue = "0") int page,
                                   Principal principal,
                                   Model model) {
        if (principal == null) return "redirect:/";

        Optional<User> operatorOpt = userRepository.findByMobile(principal.getName());
        if (operatorOpt.isEmpty()) return "redirect:/";
        User operator = operatorOpt.get();

        String trimmedQ = (q == null || q.isBlank()) ? null : q.trim();

        Instant fromAt = null;
        Instant toAt = null;
        if (date != null && !date.isBlank()) {
            try {
                LocalDate filterDate = LocalDate.parse(date);
                fromAt = filterDate.atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
                toAt = filterDate.plusDays(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
            } catch (DateTimeParseException ignored) {
            }
        }

        TransactionStatus filterStatus = null;
        if (status != null && !status.isBlank()) {
            try {
                filterStatus = TransactionStatus.valueOf(status);
            } catch (IllegalArgumentException ignored) {
            }
        }

        String filterFuelType = null;
        if (fuelType != null && !fuelType.isBlank()) {
            switch (fuelType) {
                case "petrol", "octane", "diesel" -> filterFuelType = fuelType;
                default -> {}
            }
        }

        int safePage = Math.max(page, 0);
        Page<Transaction> result = transactionRepository.findWithFilters(
                trimmedQ, null, operator.getId(), null, filterStatus, filterFuelType, fromAt, toAt,
                PageRequest.of(safePage, TRANSACTIONS_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id")));

        List<Map<String, Object>> rows = new ArrayList<>();
        for (Transaction t : result.getContent()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", t.getId());
            row.put("displayCode", "#" + t.getCode());
            row.put("createdAtDisplay", BanglaDateTime.formatDateTime(t.getCreatedAt()));
            row.put("vehiclePlate", t.getVehicle() == null ? "—" : t.getVehicle().getPlateNumber());
            row.put("amountDisplay", formatLitersAmount(t.getFuelLiters()));
            row.put("fuelTypeLabel", fuelTypeLabel(t.getFuelType()));
            row.put("fuelTypeBadgeClass", fuelTypeBadgeClass(t.getFuelType()));
            row.put("statusLabel", statusLabel(t.getStatus()));
            row.put("statusIcon", statusIcon(t.getStatus()));
            row.put("statusTone", statusTone(t.getStatus()));
            rows.add(row);
        }

        long total = result.getTotalElements();
        int shown = result.getNumberOfElements();
        long fromIdx = total == 0 ? 0 : (long) result.getNumber() * TRANSACTIONS_PAGE_SIZE + 1;
        long toIdx = total == 0 ? 0 : fromIdx + shown - 1;

        model.addAttribute("transactions", rows);
        model.addAttribute("transactionsTotal", BanglaDigits.convert(String.valueOf(total)));
        model.addAttribute("transactionsFromIdx", BanglaDigits.convert(String.valueOf(fromIdx)));
        model.addAttribute("transactionsToIdx", BanglaDigits.convert(String.valueOf(toIdx)));
        model.addAttribute("transactionsPage", result.getNumber());
        model.addAttribute("transactionsHasPrev", result.hasPrevious());
        model.addAttribute("transactionsHasNext", result.hasNext());
        model.addAttribute("transactionsPageUrl", buildOperatorTransactionsPageUrl(q, date, status, fuelType));
        model.addAttribute("filterQ", q);
        model.addAttribute("filterDate", date);
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterFuelType", fuelType);
        return "operator/transactions";
    }

    private String buildOperatorTransactionsPageUrl(String q, String date, String status, String fuelType) {
        StringBuilder sb = new StringBuilder("/operator/transactions");
        List<String> parts = new ArrayList<>();
        if (q != null && !q.isBlank()) parts.add("q=" + URLEncoder.encode(q, StandardCharsets.UTF_8));
        if (date != null && !date.isBlank()) parts.add("date=" + date);
        if (status != null && !status.isBlank()) parts.add("status=" + status);
        if (fuelType != null && !fuelType.isBlank()) parts.add("fuelType=" + fuelType);
        if (!parts.isEmpty()) sb.append("?").append(String.join("&", parts));
        return sb.toString();
    }

    @GetMapping("/transactions/new")
    public String newTransaction() {
        return "operator/new-distribution";
    }

    @PostMapping("/transactions/ocr-plate")
    @ResponseBody
    public Map<String, Object> ocrPlate(@RequestParam("photo") MultipartFile photo) {
        Map<String, Object> body = new HashMap<>();
        body.put("provider", plateOcrService.providerId());
        body.put("enabled", plateOcrService.enabled());
        body.put("plate", plateOcrService.extractPlate(photo).orElse(null));
        return body;
    }

    @PostMapping("/transactions/verify")
    @Transactional(readOnly = true)
    public String verifyDistribution(@RequestParam("plate") String plate,
                                     @RequestParam(value = "photo", required = false) MultipartFile photo,
                                     RedirectAttributes ra,
                                     Model model) {
        String trimmedPlate = plate == null ? null : plate.trim();
        if (trimmedPlate == null || trimmedPlate.isBlank()) {
            ra.addFlashAttribute("error", "প্লেট নম্বর আবশ্যক");
            return "redirect:/operator/transactions/new";
        }

        Optional<Vehicle> vehicleOpt = vehicleRepository.findFirstByPlateNumberIgnoreCase(trimmedPlate);
        if (vehicleOpt.isEmpty()) {
            ra.addFlashAttribute("error", "এই প্লেটে কোনো নিবন্ধিত যানবাহন পাওয়া যায়নি: " + trimmedPlate);
            ra.addFlashAttribute("formPlate", trimmedPlate);
            return "redirect:/operator/transactions/new";
        }
        Vehicle vehicle = vehicleOpt.get();

        String capturedPhotoPath = null;
        if (photo != null && !photo.isEmpty()) {
            try {
                capturedPhotoPath = fileStorageService.store(photo, "operator/captures");
            } catch (IllegalArgumentException e) {
                ra.addFlashAttribute("error", "শুধু JPG/PNG/WebP ছবি আপলোড করুন");
                ra.addFlashAttribute("formPlate", trimmedPlate);
                return "redirect:/operator/transactions/new";
            }
        }

        Optional<Transaction> lastTxnOpt = transactionRepository.findFirstByVehicleIdOrderByCreatedAtDesc(vehicle.getId());
        String resolvedFuelType = lastTxnOpt.map(Transaction::getFuelType).orElse("octane");
        Instant lastFueledAt = lastTxnOpt.map(Transaction::getCreatedAt).orElse(null);

        Map<String, Object> view = new HashMap<>();
        view.put("capturedPhotoUrl", capturedPhotoPath);
        view.put("detectedPlate", BanglaDigits.convert(vehicle.getPlateNumber()));
        view.put("rawPlate", vehicle.getPlateNumber());
        view.put("vehicleId", vehicle.getId());
        view.put("fuelTypeRaw", resolvedFuelType);
        view.put("fuelTypeLabel", fuelTypeLabel(resolvedFuelType));
        view.put("lastFueledDisplay", lastFueledAt == null ? "—" : BanglaDateTime.formatDate(lastFueledAt));

        User owner = vehicle.getUser();
        Map<String, Object> ownerView = new HashMap<>();
        if (owner != null) {
            UserProfile profile = owner.getProfile();
            String ownerName = profile != null && profile.getName() != null && !profile.getName().isBlank()
                    ? profile.getName()
                    : emptyToDash(owner.getName());
            ownerView.put("name", ownerName);
            ownerView.put("mobileMasked", BanglaDigits.maskMobilePartial(owner.getMobile()));
            ownerView.put("licenseMasked", profile != null ? BanglaDigits.maskLicense(profile.getLicenseNumber()) : "—");
        } else {
            ownerView.put("name", "—");
            ownerView.put("mobileMasked", "—");
            ownerView.put("licenseMasked", "—");
        }
        view.put("owner", ownerView);

        model.addAttribute("view", view);
        return "operator/verify-distribution";
    }

    @PostMapping("/transactions/select-fuel")
    @Transactional(readOnly = true)
    public String selectFuel(@RequestParam("vehicleId") Long vehicleId,
                             @RequestParam(value = "photo", required = false) MultipartFile photo,
                             Model model,
                             RedirectAttributes ra) {
        Optional<Vehicle> vehicleOpt = vehicleRepository.findById(vehicleId);
        if (vehicleOpt.isEmpty()) {
            ra.addFlashAttribute("error", "যানবাহনটি খুঁজে পাওয়া যায়নি।");
            return "redirect:/operator/transactions/new";
        }
        Vehicle vehicle = vehicleOpt.get();

        // Save the optional retaken photo; ignored if it fails validation.
        if (photo != null && !photo.isEmpty()) {
            try {
                fileStorageService.store(photo, "operator/captures");
            } catch (IllegalArgumentException ignored) {
            }
        }

        Map<String, Object> ctx = new HashMap<>();
        ctx.put("vehicleId", vehicle.getId());
        ctx.put("plateRaw", vehicle.getPlateNumber());
        ctx.put("plateDisplay", BanglaDigits.convert(vehicle.getPlateNumber()));

        User owner = vehicle.getUser();
        if (owner != null) {
            UserProfile profile = owner.getProfile();
            String ownerName = profile != null && profile.getName() != null && !profile.getName().isBlank()
                    ? profile.getName()
                    : emptyToDash(owner.getName());
            ctx.put("ownerName", ownerName);
            ctx.put("ownerPhotoUrl", profile != null ? profile.getPhotoPath() : null);
        } else {
            ctx.put("ownerName", "—");
            ctx.put("ownerPhotoUrl", null);
        }

        String defaultFuelType = transactionRepository.findFirstByVehicleIdOrderByCreatedAtDesc(vehicle.getId())
                .map(Transaction::getFuelType)
                .orElse("octane");
        ctx.put("defaultFuelType", defaultFuelType);

        model.addAttribute("ctx", ctx);
        return "operator/select-fuel";
    }

    @PostMapping("/transactions/dispense")
    @Transactional
    public String dispense(@RequestParam("vehicleId") Long vehicleId,
                           @RequestParam("fuelType") String fuelType,
                           @RequestParam("liters") BigDecimal liters,
                           Principal principal,
                           RedirectAttributes ra) {
        if (principal == null) return "redirect:/";

        Optional<User> operatorOpt = userRepository.findByMobile(principal.getName());
        if (operatorOpt.isEmpty()) return "redirect:/";
        User operator = operatorOpt.get();

        if (operator.getStation() == null) {
            ra.addFlashAttribute("error", "এই অপারেটরের জন্য কোনো স্টেশন নির্ধারিত নেই। অ্যাডমিনের সাথে যোগাযোগ করুন।");
            return "redirect:/operator/dashboard";
        }

        Optional<Vehicle> vehicleOpt = vehicleRepository.findById(vehicleId);
        if (vehicleOpt.isEmpty()) {
            ra.addFlashAttribute("error", "যানবাহনটি খুঁজে পাওয়া যায়নি।");
            return "redirect:/operator/transactions/new";
        }
        if (liters == null || liters.signum() <= 0) {
            ra.addFlashAttribute("error", "সঠিক পরিমাণ লিটার দিন।");
            return "redirect:/operator/transactions/new";
        }

        Transaction txn = Transaction.builder()
                .code(generateTransactionCode())
                .vehicle(vehicleOpt.get())
                .station(operator.getStation())
                .operator(operator)
                .fuelLiters(liters)
                .fuelType(fuelType)
                .status(TransactionStatus.SUCCESS)
                .build();
        txn = transactionRepository.save(txn);

        return "redirect:/operator/transactions/progress?id=" + txn.getId();
    }

    @GetMapping("/transactions/progress")
    @Transactional(readOnly = true)
    public String progress(@RequestParam("id") Long id, Principal principal, Model model) {
        Optional<Transaction> txnOpt = loadOwnedTransaction(id, principal);
        if (txnOpt.isEmpty()) return "redirect:/operator/dashboard";
        model.addAttribute("view", buildTxnView(txnOpt.get()));
        return "operator/progress";
    }

    @GetMapping("/transactions/success")
    @Transactional(readOnly = true)
    public String success(@RequestParam("id") Long id, Principal principal, Model model) {
        Optional<Transaction> txnOpt = loadOwnedTransaction(id, principal);
        if (txnOpt.isEmpty()) return "redirect:/operator/dashboard";
        model.addAttribute("view", buildTxnView(txnOpt.get()));
        return "operator/success";
    }

    private Optional<Transaction> loadOwnedTransaction(Long id, Principal principal) {
        if (principal == null) return Optional.empty();
        Optional<Transaction> txnOpt = transactionRepository.findById(id);
        if (txnOpt.isEmpty()) return Optional.empty();
        Transaction txn = txnOpt.get();
        User operator = txn.getOperator();
        if (operator == null || !principal.getName().equals(operator.getMobile())) {
            return Optional.empty();
        }
        return txnOpt;
    }

    private Map<String, Object> buildTxnView(Transaction txn) {
        Map<String, Object> view = new HashMap<>();
        view.put("id", txn.getId());
        view.put("code", txn.getCode());
        view.put("plateDisplay", txn.getVehicle() == null ? "—" : BanglaDigits.convert(txn.getVehicle().getPlateNumber()));
        view.put("fuelTypeLabel", fuelTypeLabel(txn.getFuelType()));
        view.put("litersDisplay", formatLitersAmount(txn.getFuelLiters()));
        view.put("litersRaw", txn.getFuelLiters() == null ? "0" : txn.getFuelLiters().toPlainString());
        return view;
    }

    private static final int TXN_CODE_MAX_ATTEMPTS = 10;

    private String generateTransactionCode() {
        for (int i = 0; i < TXN_CODE_MAX_ATTEMPTS; i++) {
            String code = "FACS-" + String.format("%06d", TXN_CODE_RNG.nextInt(1_000_000));
            if (!transactionRepository.existsByCode(code)) return code;
        }
        throw new IllegalStateException("Could not generate a unique transaction code after "
                + TXN_CODE_MAX_ATTEMPTS + " attempts");
    }

    private static String formatThousands(long value) {
        return String.format("%,d", value);
    }

    private static String formatLitersThousands(BigDecimal value) {
        long whole = value.setScale(0, RoundingMode.HALF_UP).longValueExact();
        return String.format("%,d", whole);
    }

    private static String formatLitersAmount(BigDecimal liters) {
        if (liters == null) return "—";
        return BanglaDigits.convert(liters.setScale(1, RoundingMode.HALF_UP).toPlainString()) + " লিটার";
    }

    private static String fuelTypeLabel(String fuelType) {
        if (fuelType == null) return "—";
        return switch (fuelType) {
            case "octane" -> "অকটেন";
            case "diesel" -> "ডিজেল";
            case "petrol" -> "পেট্রোল";
            default -> fuelType;
        };
    }

    private static String fuelTypeBadgeClass(String fuelType) {
        if (fuelType == null) return "bg-gray-100 text-gray-700";
        return switch (fuelType) {
            case "octane" -> "bg-indigo-50 text-indigo-700";
            case "diesel" -> "bg-brand text-white";
            case "petrol" -> "bg-brand-red text-white";
            default -> "bg-gray-100 text-gray-700";
        };
    }

    private static String statusLabel(TransactionStatus status) {
        if (status == null) return "—";
        return switch (status) {
            case SUCCESS -> "সফল";
            case PENDING -> "অপেক্ষমান";
            case CANCELLED -> "প্রত্যাখ্যাত";
        };
    }

    private static String statusIcon(TransactionStatus status) {
        if (status == null) return "info";
        return switch (status) {
            case SUCCESS -> "checkCircle";
            case CANCELLED -> "xCircle";
            case PENDING -> "clock";
        };
    }

    private static String statusTone(TransactionStatus status) {
        if (status == null) return "text-gray-500";
        return switch (status) {
            case SUCCESS -> "text-emerald-600";
            case CANCELLED -> "text-brand-red";
            case PENDING -> "text-amber-600";
        };
    }

    private static String emptyToDash(String s) {
        return (s == null || s.isBlank()) ? "—" : s;
    }
}

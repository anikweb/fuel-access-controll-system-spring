package com.invisible.facs.controller;

import com.invisible.facs.model.Role;
import com.invisible.facs.model.Station;
import com.invisible.facs.model.StationForm;
import com.invisible.facs.model.User;
import com.invisible.facs.model.UserProfile;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.StationRepository;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.repository.VehicleRepository;
import com.invisible.facs.util.BanglaDigits;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private static final int STATIONS_PAGE_SIZE = 10;
    private static final int VEHICLES_PAGE_SIZE = 10;
    private static final int STATION_CODE_MAX_ATTEMPTS = 25;
    private static final SecureRandom STATION_CODE_RNG = new SecureRandom();
    private static final String[] BANGLA_MONTHS = {
            "জানুয়ারি", "ফেব্রুয়ারি", "মার্চ", "এপ্রিল", "মে", "জুন",
            "জুলাই", "আগস্ট", "সেপ্টেম্বর", "অক্টোবর", "নভেম্বর", "ডিসেম্বর"
    };
    private static final ZoneId DHAKA_ZONE = ZoneId.of("Asia/Dhaka");

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final StationRepository stationRepository;

    @GetMapping({"", "/", "/dashboard"})
    public String dashboard(Principal principal, Model model) {
        long users = userRepository.countByRole(Role.VEHICLE_OWNER);
        long vehicles = vehicleRepository.count();
        long todayTxns = 0;

        String displayName = "";
        if (principal != null) {
            displayName = principal.getName();
        }

        model.addAttribute("displayName", displayName);
        model.addAttribute("activeUsers", BanglaDigits.convert(String.valueOf(users)));
        model.addAttribute("todayTransactions", BanglaDigits.convert(String.valueOf(todayTxns)));
        model.addAttribute("registeredVehicles", BanglaDigits.convert(String.valueOf(vehicles)));
        model.addAttribute("recentTransactions", buildPlaceholderTransactions());
        return "admin/dashboard";
    }

    private List<Map<String, String>> buildPlaceholderTransactions() {
        List<Map<String, String>> rows = new ArrayList<>();
        rows.add(createTransaction("FACS-98421", "২৪ মে, ২০২৪ | ১০:৩০ AM", "ঢাকা মেট্রো-ট ১১-৪৫২৩", "তেজগাঁও স্টেশন ০২", "১২৫.৫০ L", "সফল", "success"));
        rows.add(createTransaction("FACS-98422", "২৪ মে, ২০২৪ | ১১:১৫ AM", "চট্ট মেট্রো-ঝ ১২-৯৮৭৪", "চট্টগ্রাম বন্দর ৩", "৮০.০০ L", "অপেক্ষমান", "pending"));
        rows.add(createTransaction("FACS-98423", "২৩ মে, ২০২৪ | ০৩:৪৫ PM", "ঢাকা মেট্রো-ত ১৫-৬৬২১", "গাবতলী টার্মিনাল ১", "০.০০ L", "বাতিল", "cancelled"));
        rows.add(createTransaction("FACS-98424", "২৩ মে, ২০২৪ | ০৯:০০ AM", "ঢাকা মেট্রো-উ ১৯-০১০১", "তেজগাঁও স্টেশন ০২", "৫০.২৫ L", "সফল", "success"));
        return rows;
    }

    @GetMapping("/stations")
    public String stations(@RequestParam(name = "page", defaultValue = "0") int page, Model model) {
        int safePage = Math.max(page, 0);
        Page<Station> result = stationRepository.findAll(
                PageRequest.of(safePage, STATIONS_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id")));

        long total = result.getTotalElements();
        int shown = result.getNumberOfElements();
        long fromIdx = total == 0 ? 0 : (long) result.getNumber() * STATIONS_PAGE_SIZE + 1;
        long toIdx = total == 0 ? 0 : fromIdx + shown - 1;

        model.addAttribute("stations", result.getContent());
        model.addAttribute("stationsTotal", BanglaDigits.convert(String.valueOf(total)));
        model.addAttribute("stationsFromIdx", BanglaDigits.convert(String.valueOf(fromIdx)));
        model.addAttribute("stationsToIdx", BanglaDigits.convert(String.valueOf(toIdx)));
        model.addAttribute("stationsPage", result.getNumber());
        model.addAttribute("stationsHasPrev", result.hasPrevious());
        model.addAttribute("stationsHasNext", result.hasNext());
        return "admin/stations";
    }

    @GetMapping("/stations/new")
    public String newStationForm(Model model) {
        if (!model.containsAttribute("station")) {
            model.addAttribute("station", new StationForm());
        }
        model.addAttribute("formMode", "new");
        return "admin/stationForm";
    }

    @PostMapping("/stations")
    public String createStation(@Valid @ModelAttribute("station") StationForm form,
                                BindingResult bindingResult,
                                RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            Map<String, String> errors = bindingResult.getFieldErrors().stream()
                    .collect(Collectors.toMap(FieldError::getField, FieldError::getDefaultMessage, (a, b) -> a));
            redirectAttributes.addFlashAttribute("station", form);
            redirectAttributes.addFlashAttribute("errors", errors);
            return "redirect:/admin/stations/new";
        }
        Station station = Station.builder()
                .code(generateUniqueStationCode())
                .name(form.getName().trim())
                .location(form.getLocation().trim())
                .build();
        stationRepository.save(station);
        return "redirect:/admin/stations";
    }

    @GetMapping("/stations/{id}/edit")
    public String editStationForm(@PathVariable("id") Long id,
                                  Model model,
                                  RedirectAttributes redirectAttributes) {
        return stationRepository.findById(id)
                .map(station -> {
                    if (!model.containsAttribute("station")) {
                        StationForm form = new StationForm();
                        form.setName(station.getName());
                        form.setLocation(station.getLocation());
                        model.addAttribute("station", form);
                    }
                    model.addAttribute("formMode", "edit");
                    model.addAttribute("stationId", station.getId());
                    model.addAttribute("stationCode", station.getCode());
                    return "admin/stationForm";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("stationFlash", "স্টেশনটি খুঁজে পাওয়া যায়নি।");
                    redirectAttributes.addFlashAttribute("stationFlashVariant", "error");
                    return "redirect:/admin/stations";
                });
    }

    @PostMapping("/stations/{id}/update")
    public String updateStation(@PathVariable("id") Long id,
                                @Valid @ModelAttribute("station") StationForm form,
                                BindingResult bindingResult,
                                RedirectAttributes redirectAttributes) {
        if (bindingResult.hasErrors()) {
            Map<String, String> errors = bindingResult.getFieldErrors().stream()
                    .collect(Collectors.toMap(FieldError::getField, FieldError::getDefaultMessage, (a, b) -> a));
            redirectAttributes.addFlashAttribute("station", form);
            redirectAttributes.addFlashAttribute("errors", errors);
            return "redirect:/admin/stations/" + id + "/edit";
        }
        return stationRepository.findById(id)
                .map(station -> {
                    station.setName(form.getName().trim());
                    station.setLocation(form.getLocation().trim());
                    stationRepository.save(station);
                    redirectAttributes.addFlashAttribute("stationFlash",
                            "স্টেশন \"" + station.getName() + "\" আপডেট করা হয়েছে।");
                    redirectAttributes.addFlashAttribute("stationFlashVariant", "success");
                    return "redirect:/admin/stations";
                })
                .orElseGet(() -> {
                    redirectAttributes.addFlashAttribute("stationFlash", "স্টেশনটি খুঁজে পাওয়া যায়নি।");
                    redirectAttributes.addFlashAttribute("stationFlashVariant", "error");
                    return "redirect:/admin/stations";
                });
    }

    @PostMapping("/stations/{id}/delete")
    public String deleteStation(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        stationRepository.findById(id).ifPresentOrElse(
                station -> {
                    stationRepository.delete(station);
                    redirectAttributes.addFlashAttribute("stationFlash",
                            "স্টেশন \"" + station.getName() + "\" মুছে ফেলা হয়েছে।");
                    redirectAttributes.addFlashAttribute("stationFlashVariant", "success");
                },
                () -> {
                    redirectAttributes.addFlashAttribute("stationFlash", "স্টেশনটি খুঁজে পাওয়া যায়নি।");
                    redirectAttributes.addFlashAttribute("stationFlashVariant", "error");
                });
        return "redirect:/admin/stations";
    }

    @GetMapping("/vehicles")
    @Transactional(readOnly = true)
    public String vehicles(@RequestParam(name = "page", defaultValue = "0") int page, Model model) {
        int safePage = Math.max(page, 0);
        Page<Vehicle> result = vehicleRepository.findAll(
                PageRequest.of(safePage, VEHICLES_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id")));

        List<Map<String, Object>> rows = new ArrayList<>();
        for (Vehicle v : result.getContent()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", v.getId());
            row.put("plateNumber", v.getPlateNumber());
            row.put("brand", v.getBrand());
            row.put("model", v.getModel());
            row.put("typeLabel", vehicleTypeLabel(v.getVehicleType()));
            row.put("typeIcon", vehicleTypeIcon(v.getVehicleType()));
            row.put("ownerName", resolveOwnerName(v.getUser()));
            rows.add(row);
        }

        long total = result.getTotalElements();
        int shown = result.getNumberOfElements();
        long fromIdx = total == 0 ? 0 : (long) result.getNumber() * VEHICLES_PAGE_SIZE + 1;
        long toIdx = total == 0 ? 0 : fromIdx + shown - 1;

        model.addAttribute("vehicles", rows);
        model.addAttribute("vehiclesTotal", BanglaDigits.convert(String.valueOf(total)));
        model.addAttribute("vehiclesFromIdx", BanglaDigits.convert(String.valueOf(fromIdx)));
        model.addAttribute("vehiclesToIdx", BanglaDigits.convert(String.valueOf(toIdx)));
        model.addAttribute("vehiclesPage", result.getNumber());
        model.addAttribute("vehiclesHasPrev", result.hasPrevious());
        model.addAttribute("vehiclesHasNext", result.hasNext());
        return "admin/vehicles";
    }

    @GetMapping("/vehicles/{id}")
    @Transactional(readOnly = true)
    public String vehicleDetail(@PathVariable("id") Long id,
                                Model model,
                                RedirectAttributes redirectAttributes) {
        Optional<Vehicle> opt = vehicleRepository.findById(id);
        if (opt.isEmpty()) {
            redirectAttributes.addFlashAttribute("vehicleFlash", "যানবাহনটি খুঁজে পাওয়া যায়নি।");
            redirectAttributes.addFlashAttribute("vehicleFlashVariant", "error");
            return "redirect:/admin/vehicles";
        }
        Vehicle v = opt.get();

        String modelWithYear = v.getModel();
        if (v.getManufactureYear() != null && !v.getManufactureYear().isBlank()) {
            String year = BanglaDigits.convert(v.getManufactureYear().trim());
            modelWithYear = (modelWithYear == null || modelWithYear.isBlank())
                    ? "(" + year + ")"
                    : modelWithYear + " (" + year + ")";
        }

        Map<String, Object> view = new HashMap<>();
        view.put("id", v.getId());
        view.put("plateNumber", v.getPlateNumber());
        view.put("brand", v.getBrand());
        view.put("model", v.getModel());
        view.put("modelWithYear", modelWithYear);
        view.put("typeLabel", vehicleTypeLabel(v.getVehicleType()));
        view.put("typeIcon", vehicleTypeIcon(v.getVehicleType()));
        view.put("color", v.getColor());
        view.put("chassisNumber", v.getChassisNumber());
        view.put("engineNumber", v.getEngineNumber());
        view.put("plateImageUrl", v.getPlateImagePath());
        view.put("registeredOn", formatBanglaDate(v.getCreatedAt()));

        Map<String, Object> owner = new HashMap<>();
        User u = v.getUser();
        if (u != null) {
            owner.put("mobile", BanglaDigits.formatMobile(u.getMobile()));
            UserProfile p = u.getProfile();
            if (p != null) {
                owner.put("name", p.getName());
                owner.put("address", p.getAddress());
                owner.put("nidNumber", p.getNidNumber() == null ? null : BanglaDigits.convert(p.getNidNumber()));
                owner.put("licenseNumber", p.getLicenseNumber());
            } else if (u.getName() != null) {
                owner.put("name", u.getName());
            }
        }
        view.put("owner", owner);

        model.addAttribute("vehicle", view);
        return "admin/vehicleDetail";
    }

    @PostMapping("/vehicles/{id}/delete")
    public String deleteVehicle(@PathVariable("id") Long id, RedirectAttributes redirectAttributes) {
        vehicleRepository.findById(id).ifPresentOrElse(
                vehicle -> {
                    String label = vehicle.getPlateNumber();
                    vehicleRepository.delete(vehicle);
                    redirectAttributes.addFlashAttribute("vehicleFlash",
                            "যানবাহন \"" + label + "\" মুছে ফেলা হয়েছে।");
                    redirectAttributes.addFlashAttribute("vehicleFlashVariant", "success");
                },
                () -> {
                    redirectAttributes.addFlashAttribute("vehicleFlash", "যানবাহনটি খুঁজে পাওয়া যায়নি।");
                    redirectAttributes.addFlashAttribute("vehicleFlashVariant", "error");
                });
        return "redirect:/admin/vehicles";
    }

    private String vehicleTypeLabel(String type) {
        if (type == null) return "—";
        return switch (type) {
            case "car" -> "কার";
            case "truck" -> "ট্রাক";
            case "bike" -> "বাইক";
            default -> type;
        };
    }

    private String vehicleTypeIcon(String type) {
        if (type == null) return "car";
        return switch (type) {
            case "truck" -> "truck";
            case "bike" -> "bike";
            default -> "car";
        };
    }

    private String resolveOwnerName(User user) {
        if (user == null) return null;
        UserProfile p = user.getProfile();
        if (p != null && p.getName() != null && !p.getName().isBlank()) {
            return p.getName();
        }
        if (user.getName() != null && !user.getName().isBlank()) {
            return user.getName();
        }
        return BanglaDigits.formatMobile(user.getMobile());
    }

    private String formatBanglaDate(Instant instant) {
        if (instant == null) return null;
        LocalDate date = instant.atZone(DHAKA_ZONE).toLocalDate();
        String day = BanglaDigits.convert(String.valueOf(date.getDayOfMonth()));
        String year = BanglaDigits.convert(String.valueOf(date.getYear()));
        return day + " " + BANGLA_MONTHS[date.getMonthValue() - 1] + ", " + year;
    }

    private String generateUniqueStationCode() {
        for (int i = 0; i < STATION_CODE_MAX_ATTEMPTS; i++) {
            String code = String.format("T-%04d", STATION_CODE_RNG.nextInt(10000));
            if (!stationRepository.existsByCode(code)) return code;
        }
        throw new IllegalStateException("Could not generate a unique station code");
    }

    private Map<String, String> createTransaction(String id, String when, String vehicle, String station,
                                                  String qty, String statusLabel, String statusVariant) {
        Map<String, String> row = new HashMap<>();
        row.put("id", id);
        row.put("when", when);
        row.put("vehicle", vehicle);
        row.put("station", station);
        row.put("qty", qty);
        row.put("statusLabel", statusLabel);
        row.put("statusVariant", statusVariant);
        return row;
    }
}

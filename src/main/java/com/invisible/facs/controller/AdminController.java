package com.invisible.facs.controller;

import com.invisible.facs.model.PanelUserForm;
import com.invisible.facs.model.Role;
import com.invisible.facs.model.Station;
import com.invisible.facs.model.StationForm;
import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import com.invisible.facs.model.User;
import com.invisible.facs.model.UserProfile;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.StationRepository;
import com.invisible.facs.repository.TransactionRepository;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.repository.VehicleRepository;
import com.invisible.facs.service.FileStorageService;
import com.invisible.facs.util.BanglaDateTime;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.MobileNumbers;
import com.invisible.facs.util.PasswordRules;
import com.invisible.facs.util.TransactionDisplay;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
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
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private static final int STATIONS_PAGE_SIZE = 10;
    private static final int VEHICLES_PAGE_SIZE = 10;
    private static final int PANEL_USERS_PAGE_SIZE = 10;
    private static final int TRANSACTIONS_PAGE_SIZE = 10;
    private static final int STATION_CODE_MAX_ATTEMPTS = 25;
    private static final SecureRandom STATION_CODE_RNG = new SecureRandom();
    private static final List<Role> PANEL_USER_ROLES = List.of(Role.ADMIN, Role.OPERATOR);
    private static final String[] AVATAR_PALETTE = {
            "bg-brand text-white",
            "bg-indigo-100 text-gray-800",
            "bg-red-50 text-red-700",
            "bg-amber-50 text-amber-800",
            "bg-emerald-50 text-emerald-700",
            "bg-gray-200 text-gray-800"
    };
    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final StationRepository stationRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final FileStorageService fileStorageService;

    @GetMapping({"", "/", "/dashboard"})
    @Transactional(readOnly = true)
    public String dashboard(Principal principal, Model model) {
        long users = userRepository.countByRole(Role.VEHICLE_OWNER);
        long vehicles = vehicleRepository.count();

        LocalDate today = LocalDate.now(BanglaDateTime.DHAKA_ZONE);
        Instant todayStart = today.atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
        Instant tomorrowStart = today.plusDays(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
        long todayTxns = transactionRepository.countInRange(todayStart, tomorrowStart);

        Page<Transaction> recent = transactionRepository.findAll(
                PageRequest.of(0, 5, Sort.by(Sort.Direction.DESC, "id")));
        List<Map<String, String>> recentRows = new ArrayList<>();
        for (Transaction t : recent.getContent()) {
            Map<String, String> row = new HashMap<>();
            row.put("id", t.getCode());
            row.put("when", BanglaDateTime.formatDateTime(t.getCreatedAt()));
            row.put("vehicle", t.getVehicle() == null ? "—" : t.getVehicle().getPlateNumber());
            row.put("station", t.getStation() == null ? "—" : t.getStation().getName());
            row.put("qty", TransactionDisplay.formatLitersShort(t.getFuelLiters()));
            row.put("statusLabel", transactionStatusLabel(t.getStatus()));
            row.put("statusVariant", transactionStatusVariant(t.getStatus()));
            recentRows.add(row);
        }

        String displayName = "";
        if (principal != null) {
            displayName = principal.getName();
        }

        model.addAttribute("displayName", displayName);
        model.addAttribute("activeUsers", BanglaDigits.convert(String.valueOf(users)));
        model.addAttribute("todayTransactions", BanglaDigits.convert(String.valueOf(todayTxns)));
        model.addAttribute("registeredVehicles", BanglaDigits.convert(String.valueOf(vehicles)));
        model.addAttribute("recentTransactions", recentRows);
        return "admin/dashboard";
    }

    private String transactionStatusVariant(TransactionStatus status) {
        if (status == null) return "neutral";
        return switch (status) {
            case SUCCESS -> "success";
            case PENDING -> "pending";
            case CANCELLED -> "cancelled";
        };
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
            row.put("typeLabel", TransactionDisplay.vehicleTypeLabel(v.getVehicleType()));
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
        view.put("typeLabel", TransactionDisplay.vehicleTypeLabel(v.getVehicleType()));
        view.put("typeIcon", vehicleTypeIcon(v.getVehicleType()));
        view.put("color", v.getColor());
        view.put("chassisNumber", v.getChassisNumber());
        view.put("engineNumber", v.getEngineNumber());
        view.put("plateImageUrl", v.getPlateImagePath());
        view.put("registeredOn", BanglaDateTime.formatDate(v.getCreatedAt()));

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

    @GetMapping("/users")
    public String users(@RequestParam(name = "page", defaultValue = "0") int page, Model model) {
        int safePage = Math.max(page, 0);
        Page<User> result = userRepository.findByRoleIn(
                PANEL_USER_ROLES,
                PageRequest.of(safePage, PANEL_USERS_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id")));

        List<Map<String, Object>> rows = new ArrayList<>();
        for (User u : result.getContent()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", u.getId());
            row.put("displayId", "#" + BanglaDigits.convert(String.valueOf(u.getId())));
            row.put("name", emptyToDash(u.getName()));
            row.put("initial", initialOf(u.getName(), u.getMobile()));
            row.put("avatarClass", AVATAR_PALETTE[(int) (u.getId() % AVATAR_PALETTE.length)]);
            row.put("photoUrl", u.getPhotoPath());
            row.put("mobile", BanglaDigits.formatMobile(u.getMobile()));
            row.put("roleLabel", roleLabel(u.getRole()));
            row.put("roleBadgeClass", roleBadgeClass(u.getRole()));
            row.put("registeredOn", BanglaDateTime.formatDate(u.getCreatedAt()));
            rows.add(row);
        }

        long total = result.getTotalElements();
        int shown = result.getNumberOfElements();
        long fromIdx = total == 0 ? 0 : (long) result.getNumber() * PANEL_USERS_PAGE_SIZE + 1;
        long toIdx = total == 0 ? 0 : fromIdx + shown - 1;

        model.addAttribute("panelUsers", rows);
        model.addAttribute("panelUsersTotal", BanglaDigits.convert(String.valueOf(total)));
        model.addAttribute("panelUsersFromIdx", BanglaDigits.convert(String.valueOf(fromIdx)));
        model.addAttribute("panelUsersToIdx", BanglaDigits.convert(String.valueOf(toIdx)));
        model.addAttribute("panelUsersPage", result.getNumber());
        model.addAttribute("panelUsersHasPrev", result.hasPrevious());
        model.addAttribute("panelUsersHasNext", result.hasNext());
        return "admin/users";
    }

    @GetMapping("/users/new")
    public String newUserForm(Model model) {
        if (!model.containsAttribute("panelUser")) {
            PanelUserForm form = new PanelUserForm();
            form.setRole(Role.OPERATOR.name());
            model.addAttribute("panelUser", form);
        }
        model.addAttribute("formMode", "new");
        model.addAttribute("stations", loadStationOptions());
        return "admin/userForm";
    }

    @PostMapping("/users")
    public String createUser(@Valid @ModelAttribute("panelUser") PanelUserForm form,
                             BindingResult bindingResult,
                             RedirectAttributes redirectAttributes) {
        Role role = parsePanelRole(form.getRole());
        if (role == null) {
            bindingResult.rejectValue("role", "invalid", "অবৈধ ভূমিকা");
        }
        String normalizedMobile = MobileNumbers.normalize(form.getMobile());
        if (normalizedMobile == null) {
            bindingResult.rejectValue("mobile", "invalid", "সঠিক মোবাইল নম্বর দিন");
        } else if (userRepository.findByMobile(normalizedMobile).isPresent()) {
            bindingResult.rejectValue("mobile", "duplicate", "এই মোবাইল নম্বর ইতিমধ্যে ব্যবহৃত");
        }
        Station station = resolveStation(role, form.getStationId(), bindingResult);
        validatePassword(form.getPassword(), form.getPasswordConfirm(), true, bindingResult);

        if (bindingResult.hasErrors()) {
            flashFormErrors(form, bindingResult, redirectAttributes);
            return "redirect:/admin/users/new";
        }

        String photoPath = storePhotoOrReject(form.getPhoto(), bindingResult);
        if (bindingResult.hasErrors()) {
            flashFormErrors(form, bindingResult, redirectAttributes);
            return "redirect:/admin/users/new";
        }

        User user = User.builder()
                .name(form.getName().trim())
                .mobile(normalizedMobile)
                .passwordHash(passwordEncoder.encode(form.getPassword()))
                .role(role)
                .station(station)
                .photoPath(photoPath)
                .build();
        userRepository.save(user);
        redirectAttributes.addFlashAttribute("panelUserFlash",
                "ব্যবহারকারী \"" + user.getName() + "\" তৈরি হয়েছে।");
        redirectAttributes.addFlashAttribute("panelUserFlashVariant", "success");
        return "redirect:/admin/users";
    }

    @GetMapping("/users/{id}/edit")
    @Transactional(readOnly = true)
    public String editUserForm(@PathVariable("id") Long id,
                               Model model,
                               RedirectAttributes redirectAttributes) {
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty() || !PANEL_USER_ROLES.contains(opt.get().getRole())) {
            redirectAttributes.addFlashAttribute("panelUserFlash", "ব্যবহারকারীটি খুঁজে পাওয়া যায়নি।");
            redirectAttributes.addFlashAttribute("panelUserFlashVariant", "error");
            return "redirect:/admin/users";
        }
        User u = opt.get();
        if (!model.containsAttribute("panelUser")) {
            PanelUserForm form = new PanelUserForm();
            form.setName(u.getName());
            form.setMobile(u.getMobile());
            form.setRole(u.getRole().name());
            if (u.getStation() != null) form.setStationId(u.getStation().getId());
            model.addAttribute("panelUser", form);
        }
        model.addAttribute("formMode", "edit");
        model.addAttribute("panelUserId", u.getId());
        model.addAttribute("existingPhotoUrl", u.getPhotoPath());
        model.addAttribute("stations", loadStationOptions());
        return "admin/userForm";
    }

    @PostMapping("/users/{id}/update")
    public String updateUser(@PathVariable("id") Long id,
                             @Valid @ModelAttribute("panelUser") PanelUserForm form,
                             BindingResult bindingResult,
                             RedirectAttributes redirectAttributes) {
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty() || !PANEL_USER_ROLES.contains(opt.get().getRole())) {
            redirectAttributes.addFlashAttribute("panelUserFlash", "ব্যবহারকারীটি খুঁজে পাওয়া যায়নি।");
            redirectAttributes.addFlashAttribute("panelUserFlashVariant", "error");
            return "redirect:/admin/users";
        }
        User user = opt.get();

        Role role = parsePanelRole(form.getRole());
        if (role == null) {
            bindingResult.rejectValue("role", "invalid", "অবৈধ ভূমিকা");
        }
        String normalizedMobile = MobileNumbers.normalize(form.getMobile());
        if (normalizedMobile == null) {
            bindingResult.rejectValue("mobile", "invalid", "সঠিক মোবাইল নম্বর দিন");
        } else if (!normalizedMobile.equals(user.getMobile())
                && userRepository.findByMobile(normalizedMobile).isPresent()) {
            bindingResult.rejectValue("mobile", "duplicate", "এই মোবাইল নম্বর ইতিমধ্যে ব্যবহৃত");
        }
        Station station = resolveStation(role, form.getStationId(), bindingResult);
        boolean wantsPasswordChange = (form.getPassword() != null && !form.getPassword().isEmpty())
                || (form.getPasswordConfirm() != null && !form.getPasswordConfirm().isEmpty());
        validatePassword(form.getPassword(), form.getPasswordConfirm(), wantsPasswordChange, bindingResult);

        if (bindingResult.hasErrors()) {
            flashFormErrors(form, bindingResult, redirectAttributes);
            return "redirect:/admin/users/" + id + "/edit";
        }

        String newPhotoPath = storePhotoOrReject(form.getPhoto(), bindingResult);
        if (bindingResult.hasErrors()) {
            flashFormErrors(form, bindingResult, redirectAttributes);
            return "redirect:/admin/users/" + id + "/edit";
        }

        user.setName(form.getName().trim());
        user.setMobile(normalizedMobile);
        user.setRole(role);
        user.setStation(station);
        if (wantsPasswordChange) {
            user.setPasswordHash(passwordEncoder.encode(form.getPassword()));
        }
        if (newPhotoPath != null) {
            String oldPhotoPath = user.getPhotoPath();
            user.setPhotoPath(newPhotoPath);
            if (oldPhotoPath != null) fileStorageService.delete(oldPhotoPath);
        }
        userRepository.save(user);
        redirectAttributes.addFlashAttribute("panelUserFlash",
                "ব্যবহারকারী \"" + user.getName() + "\" আপডেট করা হয়েছে।");
        redirectAttributes.addFlashAttribute("panelUserFlashVariant", "success");
        return "redirect:/admin/users";
    }

    @PostMapping("/users/{id}/delete")
    public String deleteUser(@PathVariable("id") Long id,
                             Principal principal,
                             RedirectAttributes redirectAttributes) {
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty() || !PANEL_USER_ROLES.contains(opt.get().getRole())) {
            redirectAttributes.addFlashAttribute("panelUserFlash", "ব্যবহারকারীটি খুঁজে পাওয়া যায়নি।");
            redirectAttributes.addFlashAttribute("panelUserFlashVariant", "error");
            return "redirect:/admin/users";
        }
        User user = opt.get();
        if (principal != null && user.getMobile().equals(principal.getName())) {
            redirectAttributes.addFlashAttribute("panelUserFlash", "নিজের অ্যাকাউন্ট মুছে ফেলা যাবে না।");
            redirectAttributes.addFlashAttribute("panelUserFlashVariant", "error");
            return "redirect:/admin/users";
        }
        String label = emptyToDash(user.getName());
        userRepository.delete(user);
        redirectAttributes.addFlashAttribute("panelUserFlash",
                "ব্যবহারকারী \"" + label + "\" মুছে ফেলা হয়েছে।");
        redirectAttributes.addFlashAttribute("panelUserFlashVariant", "success");
        return "redirect:/admin/users";
    }

    @GetMapping("/transactions")
    @Transactional(readOnly = true)
    public String transactions(
            @RequestParam(name = "q", required = false) String q,
            @RequestParam(name = "date", required = false) String date,
            @RequestParam(name = "stationId", required = false) Long stationId,
            @RequestParam(name = "status", required = false) String status,
            @RequestParam(name = "page", defaultValue = "0") int page,
            Model model) {

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

        int safePage = Math.max(page, 0);
        Page<Transaction> result = transactionRepository.findWithFilters(
                trimmedQ, stationId, null, null, filterStatus, null, fromAt, toAt,
                PageRequest.of(safePage, TRANSACTIONS_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id")));

        List<Map<String, Object>> rows = new ArrayList<>();
        for (Transaction t : result.getContent()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", t.getId());
            row.put("displayCode", "#" + t.getCode());
            row.put("createdAtDisplay", BanglaDateTime.formatDateTime(t.getCreatedAt()));
            row.put("vehiclePlate", t.getVehicle() == null ? null : t.getVehicle().getPlateNumber());
            row.put("stationName", t.getStation() == null ? null : t.getStation().getName());
            row.put("amountDisplay", TransactionDisplay.formatLitersShort(t.getFuelLiters()));
            row.put("statusLabel", transactionStatusLabel(t.getStatus()));
            row.put("statusBadgeClass", TransactionDisplay.statusBadgeClass(t.getStatus()));
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
        model.addAttribute("transactionsPageUrl", buildTransactionsPageUrl(q, date, stationId, status));
        model.addAttribute("stations", loadStationOptions());
        model.addAttribute("filterQ", q);
        model.addAttribute("filterDate", date);
        model.addAttribute("filterStationId", stationId);
        model.addAttribute("filterStatus", status);
        return "admin/transactions";
    }

    private String buildTransactionsPageUrl(String q, String date, Long stationId, String status) {
        StringBuilder sb = new StringBuilder("/admin/transactions");
        List<String> parts = new ArrayList<>();
        if (q != null && !q.isBlank()) parts.add("q=" + URLEncoder.encode(q, StandardCharsets.UTF_8));
        if (date != null && !date.isBlank()) parts.add("date=" + date);
        if (stationId != null) parts.add("stationId=" + stationId);
        if (status != null && !status.isBlank()) parts.add("status=" + status);
        if (!parts.isEmpty()) sb.append("?").append(String.join("&", parts));
        return sb.toString();
    }

    private String transactionStatusLabel(TransactionStatus status) {
        if (status == null) return "—";
        return switch (status) {
            case SUCCESS -> "সফল";
            case PENDING -> "অপেক্ষমান";
            case CANCELLED -> "বাতিল";
        };
    }

    private String storePhotoOrReject(org.springframework.web.multipart.MultipartFile photo,
                                      BindingResult bindingResult) {
        if (photo == null || photo.isEmpty()) return null;
        try {
            return fileStorageService.store(photo, "panel/photos");
        } catch (IllegalArgumentException e) {
            bindingResult.rejectValue("photo", "invalid", "শুধু JPG, PNG বা WebP ছবি আপলোড করুন");
            return null;
        } catch (IllegalStateException e) {
            bindingResult.rejectValue("photo", "save", "ছবি সংরক্ষণে ব্যর্থ");
            return null;
        }
    }

    private List<Map<String, Object>> loadStationOptions() {
        List<Map<String, Object>> options = new ArrayList<>();
        for (Station s : stationRepository.findAll(Sort.by(Sort.Direction.ASC, "name"))) {
            Map<String, Object> opt = new HashMap<>();
            opt.put("id", s.getId());
            opt.put("name", s.getName());
            opt.put("code", s.getCode());
            options.add(opt);
        }
        return options;
    }

    private Station resolveStation(Role role, Long stationId, BindingResult bindingResult) {
        if (role != Role.OPERATOR) {
            return null;
        }
        if (stationId == null) {
            bindingResult.rejectValue("stationId", "required", "অপারেটরের জন্য স্টেশন আবশ্যক");
            return null;
        }
        Optional<Station> stationOpt = stationRepository.findById(stationId);
        if (stationOpt.isEmpty()) {
            bindingResult.rejectValue("stationId", "invalid", "অবৈধ স্টেশন");
            return null;
        }
        return stationOpt.get();
    }

    private Role parsePanelRole(String raw) {
        if (raw == null) return null;
        try {
            Role r = Role.valueOf(raw);
            return PANEL_USER_ROLES.contains(r) ? r : null;
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private void validatePassword(String password, String passwordConfirm,
                                  boolean required, BindingResult bindingResult) {
        if (!required && (password == null || password.isEmpty())) {
            return;
        }
        if (password == null || password.isEmpty()) {
            bindingResult.rejectValue("password", "required", "পাসওয়ার্ড আবশ্যক");
        } else if (!PasswordRules.isValid(password)) {
            bindingResult.rejectValue("password", "weak", PasswordRules.PATTERN_MESSAGE);
        }
        if (passwordConfirm == null || !passwordConfirm.equals(password)) {
            bindingResult.rejectValue("passwordConfirm", "mismatch", "পাসওয়ার্ড মেলেনি");
        }
    }

    private void flashFormErrors(PanelUserForm form, BindingResult bindingResult,
                                 RedirectAttributes redirectAttributes) {
        Map<String, String> errors = bindingResult.getFieldErrors().stream()
                .collect(Collectors.toMap(FieldError::getField, FieldError::getDefaultMessage, (a, b) -> a));
        form.setPassword(null);
        form.setPasswordConfirm(null);
        redirectAttributes.addFlashAttribute("panelUser", form);
        redirectAttributes.addFlashAttribute("errors", errors);
    }

    private String roleLabel(Role role) {
        if (role == null) return "—";
        return switch (role) {
            case ADMIN -> "সিস্টেম অ্যাডমিন";
            case OPERATOR -> "অপারেটর";
            default -> role.name();
        };
    }

    private String roleBadgeClass(Role role) {
        if (role == null) return "bg-gray-100 text-gray-700";
        return switch (role) {
            case ADMIN -> "bg-indigo-100 text-gray-800";
            case OPERATOR -> "bg-brand/5 text-brand";
            default -> "bg-gray-100 text-gray-700";
        };
    }

    private String initialOf(String name, String mobile) {
        String source = (name == null || name.isBlank()) ? mobile : name.trim();
        if (source == null || source.isEmpty()) return "—";
        int cp = source.codePointAt(0);
        return new String(Character.toChars(cp));
    }

    private String emptyToDash(String s) {
        return (s == null || s.isBlank()) ? "—" : s;
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

    private String generateUniqueStationCode() {
        for (int i = 0; i < STATION_CODE_MAX_ATTEMPTS; i++) {
            String code = String.format("T-%04d", STATION_CODE_RNG.nextInt(10000));
            if (!stationRepository.existsByCode(code)) return code;
        }
        throw new IllegalStateException("Could not generate a unique station code");
    }

}

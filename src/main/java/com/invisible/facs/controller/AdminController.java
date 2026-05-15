package com.invisible.facs.controller;

import com.invisible.facs.model.Role;
import com.invisible.facs.model.Station;
import com.invisible.facs.model.StationForm;
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
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private static final int STATIONS_PAGE_SIZE = 10;
    private static final int STATION_CODE_MAX_ATTEMPTS = 25;
    private static final SecureRandom STATION_CODE_RNG = new SecureRandom();

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
                PageRequest.of(safePage, STATIONS_PAGE_SIZE, Sort.by(Sort.Direction.ASC, "id")));

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

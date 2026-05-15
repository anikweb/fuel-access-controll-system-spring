package com.invisible.facs.controller;

import com.invisible.facs.model.Role;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.repository.VehicleRepository;
import com.invisible.facs.util.BanglaDigits;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.security.Principal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;

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

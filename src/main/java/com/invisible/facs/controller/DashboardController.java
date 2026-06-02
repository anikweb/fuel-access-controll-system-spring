package com.invisible.facs.controller;

import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import com.invisible.facs.model.User;
import com.invisible.facs.repository.TransactionRepository;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.service.UserService;
import com.invisible.facs.util.BanglaDateTime;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.TransactionDisplay;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.Principal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequiredArgsConstructor
public class DashboardController {

    private static final int TRANSACTIONS_PAGE_SIZE = 15;

    private final UserService userService;
    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;

    @GetMapping("/dashboard")
    public String dashboard(Principal principal, Model model) {
        return userService.prepareDashboard(principal, model);
    }

    @GetMapping("/transactions")
    @Transactional(readOnly = true)
    public String transactions(@RequestParam(name = "q", required = false) String q,
                               @RequestParam(name = "date", required = false) String date,
                               @RequestParam(name = "status", required = false) String status,
                               @RequestParam(name = "page", defaultValue = "0") int page,
                               Principal principal,
                               Model model) {
        if (principal == null) return "redirect:/";
        Optional<User> userOpt = userRepository.findByMobile(principal.getName());
        if (userOpt.isEmpty()) return "redirect:/";
        User user = userOpt.get();

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
                trimmedQ, null, null, user.getId(), filterStatus, null, fromAt, toAt,
                PageRequest.of(safePage, TRANSACTIONS_PAGE_SIZE, Sort.by(Sort.Direction.DESC, "id")));

        List<Map<String, Object>> rows = new ArrayList<>();
        for (Transaction t : result.getContent()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", t.getId());
            row.put("displayCode", "#" + t.getCode());
            row.put("createdAtDisplay", BanglaDateTime.formatDateTime(t.getCreatedAt()));
            row.put("vehiclePlate", t.getVehicle() == null ? "—" : BanglaDigits.convert(t.getVehicle().getPlateNumber()));
            row.put("stationName", t.getStation() == null ? "—" : t.getStation().getName());
            row.put("amountDisplay", TransactionDisplay.formatLitersShort(t.getFuelLiters()));
            row.put("statusLabel", statusLabel(t.getStatus()));
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
        model.addAttribute("transactionsPageUrl", buildPageUrl(q, date, status));
        model.addAttribute("filterQ", q);
        model.addAttribute("filterDate", date);
        model.addAttribute("filterStatus", status);
        model.addAttribute("userSidebar", UserService.buildUserSidebar(user));
        return "user/transactions";
    }

    private static String buildPageUrl(String q, String date, String status) {
        StringBuilder sb = new StringBuilder("/transactions");
        List<String> parts = new ArrayList<>();
        if (q != null && !q.isBlank()) parts.add("q=" + URLEncoder.encode(q, StandardCharsets.UTF_8));
        if (date != null && !date.isBlank()) parts.add("date=" + date);
        if (status != null && !status.isBlank()) parts.add("status=" + status);
        if (!parts.isEmpty()) sb.append("?").append(String.join("&", parts));
        return sb.toString();
    }

    private static String statusLabel(TransactionStatus status) {
        if (status == null) return "—";
        return switch (status) {
            case SUCCESS -> "সফল";
            case PENDING -> "অপেক্ষমান";
            case CANCELLED -> "বাতিল";
        };
    }
}

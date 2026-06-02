package com.invisible.facs.service;

import com.invisible.facs.model.OtpPurpose;
import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import com.invisible.facs.model.User;
import com.invisible.facs.model.UserProfile;
import com.invisible.facs.repository.TransactionRepository;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.util.BanglaDateTime;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.MobileNumbers;
import com.invisible.facs.util.PasswordRules;
import com.invisible.facs.util.TransactionDisplay;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.VehicleRepository;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.security.Principal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private static final String S_MOBILE = "resetMobile";
    private static final String S_VERIFIED = "resetVerified";

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final OtpService otpService;

    @Transactional(readOnly = true)
    public String prepareDashboard(Principal principal, Model model) {
        if (principal == null) {
            return "redirect:/";
        }
        String mobile = principal.getName();
        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) {
            return "redirect:/";
        }
        User user = userOpt.get();

        UserProfile profile = user.getProfile();
        List<Vehicle> vehicles = vehicleRepository.findByUserIdOrderByCreatedAtDesc(user.getId());

        LocalDate today = LocalDate.now(BanglaDateTime.DHAKA_ZONE);
        Instant monthStart = today.withDayOfMonth(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
        Instant monthEnd = today.withDayOfMonth(1).plusMonths(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
        Instant todayStart = today.atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
        Instant tomorrowStart = today.plusDays(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();

        Map<Long, BigDecimal> usedByVehicle = new HashMap<>();
        for (Object[] row : transactionRepository.sumLitersByVehicleForUserInRange(
                user.getId(), TransactionStatus.SUCCESS, monthStart, monthEnd)) {
            usedByVehicle.put((Long) row[0], (BigDecimal) row[1]);
        }

        Map<Long, Instant> lastRefueledByVehicle = new LinkedHashMap<>();
        for (Transaction t : transactionRepository.findTop10ByVehicleUserIdOrderByCreatedAtDesc(user.getId())) {
            if (t.getStatus() != TransactionStatus.SUCCESS || t.getVehicle() == null) continue;
            lastRefueledByVehicle.putIfAbsent(t.getVehicle().getId(), t.getCreatedAt());
        }

        List<Map<String, Object>> vehicleCards = new ArrayList<>();
        boolean anyEligibleToday = false;
        Instant aggregateLastRefueled = null;
        for (Vehicle v : vehicles) {
            BigDecimal used = usedByVehicle.getOrDefault(v.getId(), BigDecimal.ZERO);
            BigDecimal quota = v.getMonthlyQuotaLiters() != null ? v.getMonthlyQuotaLiters() : BigDecimal.ZERO;
            int percentUsed = 0;
            if (quota.signum() > 0) {
                percentUsed = used.multiply(BigDecimal.valueOf(100))
                        .divide(quota, 0, RoundingMode.HALF_UP)
                        .min(BigDecimal.valueOf(100))
                        .intValueExact();
            }
            Instant lastRefueled = lastRefueledByVehicle.get(v.getId());
            boolean refueledToday = lastRefueled != null && !lastRefueled.isBefore(todayStart);
            if (!refueledToday) anyEligibleToday = true;
            if (lastRefueled != null && (aggregateLastRefueled == null || lastRefueled.isAfter(aggregateLastRefueled))) {
                aggregateLastRefueled = lastRefueled;
            }

            Map<String, Object> card = new HashMap<>();
            card.put("plateNumber", v.getPlateNumber());
            card.put("plateDisplay", BanglaDigits.convert(v.getPlateNumber()));
            card.put("brand", v.getBrand());
            card.put("model", v.getModel());
            card.put("type", TransactionDisplay.vehicleTypeLabel(v.getVehicleType()));
            card.put("color", v.getColor());
            card.put("year", v.getManufactureYear());
            card.put("plateImageUrl", v.getPlateImagePath());
            card.put("quotaDisplay", formatLiters(quota));
            card.put("usedDisplay", formatLiters(used));
            card.put("percentUsed", percentUsed);
            card.put("percentUsedDisplay", BanglaDigits.convert(String.valueOf(percentUsed)) + "%");
            vehicleCards.add(card);
        }

        Map<String, Object> eligibility = new HashMap<>();
        eligibility.put("hasVehicles", !vehicles.isEmpty());
        eligibility.put("eligible", anyEligibleToday);
        eligibility.put("badgeLabel", anyEligibleToday ? "যোগ্য" : "আজকের কোটা শেষ");
        eligibility.put("badgeClass", anyEligibleToday
                ? "bg-emerald-50 text-emerald-700 border-emerald-200"
                : "bg-amber-50 text-amber-700 border-amber-200");
        eligibility.put("lastRefueledDisplay", aggregateLastRefueled == null
                ? "এখনো কোনো রিফুয়েলিং নেই"
                : BanglaDateTime.formatRelativeDay(aggregateLastRefueled));
        eligibility.put("nextEligibleDisplay", anyEligibleToday
                ? "এখনই উপলব্ধ"
                : BanglaDateTime.formatRelativeDay(tomorrowStart));

        List<Map<String, Object>> recentRows = new ArrayList<>();
        for (Transaction t : transactionRepository.findTop10ByVehicleUserIdOrderByCreatedAtDesc(user.getId())) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", t.getId());
            row.put("displayCode", "#" + t.getCode());
            row.put("createdAtDisplay", BanglaDateTime.formatDateTime(t.getCreatedAt()));
            row.put("stationName", t.getStation() == null ? "—" : t.getStation().getName());
            row.put("amountDisplay", TransactionDisplay.formatLitersShort(t.getFuelLiters()));
            row.put("statusLabel", transactionStatusLabel(t.getStatus()));
            row.put("statusBadgeClass", TransactionDisplay.statusBadgeClass(t.getStatus()));
            recentRows.add(row);
        }

        Map<String, Object> profileCard = null;
        if (profile != null) {
            profileCard = new HashMap<>();
            profileCard.put("photoUrl", profile.getPhotoPath());
            profileCard.put("name", profile.getName());
        }

        String displayName = resolveDisplayName(user);

        Map<String, Object> view = new HashMap<>();
        view.put("displayName", displayName);
        view.put("mobile", BanglaDigits.formatMobile(user.getMobile()));
        view.put("profile", profileCard);
        view.put("vehicles", vehicleCards);
        view.put("eligibility", eligibility);
        view.put("recentTransactions", recentRows);

        model.addAttribute("view", view);
        model.addAttribute("userSidebar", buildUserSidebar(user));
        return "user/dashboard";
    }

    public static Map<String, Object> buildUserSidebar(User user) {
        UserProfile p = user.getProfile();
        Map<String, Object> sidebar = new HashMap<>();
        sidebar.put("photoUrl", p == null ? null : p.getPhotoPath());
        sidebar.put("name", resolveDisplayName(user));
        sidebar.put("roleLabel", "গাড়ির মালিক");
        return sidebar;
    }

    private static String resolveDisplayName(User user) {
        UserProfile p = user.getProfile();
        if (p != null && p.getName() != null && !p.getName().isBlank()) return p.getName();
        if (user.getName() != null && !user.getName().isBlank()) return user.getName();
        return user.getMobile();
    }

    private static String formatLiters(BigDecimal liters) {
        if (liters == null) return "০ লিটার";
        return BanglaDigits.convert(liters.setScale(2, RoundingMode.HALF_UP).toPlainString()) + " লিটার";
    }

    private static String transactionStatusLabel(TransactionStatus status) {
        if (status == null) return "—";
        return switch (status) {
            case SUCCESS -> "সফল";
            case PENDING -> "অপেক্ষমান";
            case CANCELLED -> "বাতিল";
        };
    }

    public String requestPasswordReset(String rawMobile, HttpSession session) {
        String mobile = MobileNumbers.normalize(rawMobile);

        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) {
            return "redirect:/forgot-password?error=notFound";
        }

        session.setAttribute(S_MOBILE, mobile);
        session.removeAttribute(S_VERIFIED);
        try {
            otpService.issue(mobile, OtpPurpose.PASSWORD_RESET);
        } catch (RuntimeException e) {
            log.warn("Password-reset OTP send failed: {}", e.getMessage());
            return "redirect:/forgot-password?smsError=generic";
        }
        return "redirect:/verify-otp";
    }

    public String verifyResetOtp(String code, HttpSession session) {
        String mobile = (String) session.getAttribute(S_MOBILE);
        if (mobile == null) return "redirect:/forgot-password";

        if (!otpService.verify(mobile, OtpPurpose.PASSWORD_RESET, code)) {
            return "redirect:/verify-otp?error";
        }
        session.setAttribute(S_VERIFIED, Boolean.TRUE);
        return "redirect:/reset-password";
    }

    public String resendResetOtp(HttpSession session) {
        String mobile = (String) session.getAttribute(S_MOBILE);
        if (mobile == null) return "redirect:/forgot-password";
        try {
            otpService.issue(mobile, OtpPurpose.PASSWORD_RESET);
        } catch (RuntimeException e) {
            log.warn("Password-reset OTP resend failed: {}", e.getMessage());
            return "redirect:/verify-otp?smsError=generic";
        }
        return "redirect:/verify-otp?resent";
    }

    @Transactional
    public String submitNewPassword(String password, String passwordConfirm, HttpSession session) {
        if (!isResetVerified(session)) return "redirect:/forgot-password";

        if (!PasswordRules.isValid(password)) {
            return "redirect:/reset-password?error=weak";
        }
        if (!password.equals(passwordConfirm)) {
            return "redirect:/reset-password?error=mismatch";
        }

        String mobile = (String) session.getAttribute(S_MOBILE);
        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) {
            session.removeAttribute(S_MOBILE);
            session.removeAttribute(S_VERIFIED);
            return "redirect:/forgot-password";
        }
        User user = userOpt.get();
        user.setPasswordHash(passwordEncoder.encode(password));
        userRepository.save(user);

        session.invalidate();
        return "redirect:/?passwordReset";
    }

    public boolean isResetVerified(HttpSession session) {
        if (!Boolean.TRUE.equals(session.getAttribute(S_VERIFIED))) return false;
        if (session.getAttribute(S_MOBILE) == null) return false;
        return true;
    }

    public String getResetMobile(HttpSession session) {
        return (String) session.getAttribute(S_MOBILE);
    }

    public enum ChangePasswordResult {
        SUCCESS, INVALID_CURRENT, WEAK, MISMATCH, SAME_AS_CURRENT, USER_MISSING
    }

    @Transactional
    public ChangePasswordResult changePassword(String mobile, String currentPassword,
                                               String newPassword, String confirmPassword) {
        if (mobile == null) return ChangePasswordResult.USER_MISSING;
        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) return ChangePasswordResult.USER_MISSING;
        User user = userOpt.get();

        if (currentPassword == null || !passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            return ChangePasswordResult.INVALID_CURRENT;
        }
        if (!PasswordRules.isValid(newPassword)) {
            return ChangePasswordResult.WEAK;
        }
        if (!newPassword.equals(confirmPassword)) {
            return ChangePasswordResult.MISMATCH;
        }
        if (passwordEncoder.matches(newPassword, user.getPasswordHash())) {
            return ChangePasswordResult.SAME_AS_CURRENT;
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        return ChangePasswordResult.SUCCESS;
    }
}

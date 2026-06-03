package com.invisible.facs.service;

import com.invisible.facs.model.EligibilitySettings;
import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.EligibilitySettingsRepository;
import com.invisible.facs.repository.TransactionRepository;
import com.invisible.facs.repository.VehicleRepository;
import com.invisible.facs.util.BanglaDateTime;
import com.invisible.facs.util.BanglaDigits;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class EligibilityService {

    public static final BigDecimal DEFAULT_QUOTA_LITERS = new BigDecimal("60.00");
    public static final int DEFAULT_COOLDOWN_HOURS = 24;

    private final EligibilitySettingsRepository settingsRepository;
    private final TransactionRepository transactionRepository;
    private final VehicleRepository vehicleRepository;

    @Transactional
    public EligibilitySettings getOrCreate() {
        return settingsRepository.findById(EligibilitySettings.SINGLETON_ID)
                .orElseGet(() -> settingsRepository.save(EligibilitySettings.builder()
                        .id(EligibilitySettings.SINGLETON_ID)
                        .monthlyQuotaLiters(DEFAULT_QUOTA_LITERS)
                        .cooldownHours(DEFAULT_COOLDOWN_HOURS)
                        .build()));
    }

    @Transactional
    public EligibilitySettings save(BigDecimal monthlyQuotaLiters, Integer cooldownHours) {
        EligibilitySettings s = getOrCreate();
        s.setMonthlyQuotaLiters(monthlyQuotaLiters);
        s.setCooldownHours(cooldownHours);
        return settingsRepository.save(s);
    }

    /**
     * Resolves the effective quota/cooldown for a vehicle: vehicle override when set, else global default.
     */
    @Transactional(readOnly = true)
    public Effective resolveEffective(Long vehicleId) {
        EligibilitySettings global = getOrCreate();
        Vehicle vehicle = vehicleRepository.findById(vehicleId).orElse(null);
        BigDecimal quota = vehicle != null && vehicle.getMonthlyQuotaLiters() != null
                ? vehicle.getMonthlyQuotaLiters() : global.getMonthlyQuotaLiters();
        boolean quotaOverridden = vehicle != null && vehicle.getMonthlyQuotaLiters() != null;
        Integer cooldown = vehicle != null && vehicle.getCooldownHours() != null
                ? vehicle.getCooldownHours() : global.getCooldownHours();
        boolean cooldownOverridden = vehicle != null && vehicle.getCooldownHours() != null;
        return new Effective(quota, quotaOverridden, cooldown, cooldownOverridden,
                global.getMonthlyQuotaLiters(), global.getCooldownHours());
    }

    @Transactional(readOnly = true)
    public Result check(Long vehicleId) {
        return check(vehicleId, null);
    }

    /**
     * Eligibility check for a vehicle, optionally accounting for an incoming dispense of {@code requestedLiters}.
     */
    @Transactional(readOnly = true)
    public Result check(Long vehicleId, BigDecimal requestedLiters) {
        Effective eff = resolveEffective(vehicleId);
        BigDecimal quota = eff.monthlyQuotaLiters();
        int cooldownHours = eff.cooldownHours();

        LocalDate today = LocalDate.now(BanglaDateTime.DHAKA_ZONE);
        YearMonth ym = YearMonth.from(today);
        Instant monthStart = ym.atDay(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();
        Instant monthEnd = ym.plusMonths(1).atDay(1).atStartOfDay(BanglaDateTime.DHAKA_ZONE).toInstant();

        BigDecimal usedThisMonth = transactionRepository.sumFuelLitersByVehicleInRange(
                vehicleId, TransactionStatus.SUCCESS, monthStart, monthEnd);
        if (usedThisMonth == null) usedThisMonth = BigDecimal.ZERO;

        BigDecimal remaining = quota.subtract(usedThisMonth);
        if (remaining.signum() < 0) remaining = BigDecimal.ZERO;

        Optional<Transaction> lastSuccessOpt = transactionRepository
                .findFirstByVehicleIdAndStatusOrderByCreatedAtDesc(vehicleId, TransactionStatus.SUCCESS);
        Instant lastSuccessAt = lastSuccessOpt.map(Transaction::getCreatedAt).orElse(null);
        Instant nextEligibleAt = lastSuccessAt == null ? null
                : lastSuccessAt.plusSeconds((long) cooldownHours * 3600L);
        boolean inCooldown = nextEligibleAt != null && Instant.now().isBefore(nextEligibleAt);

        boolean quotaExhausted = remaining.signum() == 0;
        boolean requestExceedsRemaining = requestedLiters != null
                && requestedLiters.signum() > 0
                && requestedLiters.compareTo(remaining) > 0;

        boolean eligible = !inCooldown && !quotaExhausted && !requestExceedsRemaining;

        String reason = null;
        if (inCooldown) {
            reason = "এই যানবাহনের পরবর্তী রিফুয়েলিং " + BanglaDateTime.formatDateTime(nextEligibleAt)
                    + " এর পর সম্ভব। (অপেক্ষমান সময়: " + BanglaDigits.convert(String.valueOf(cooldownHours))
                    + " ঘণ্টা)";
        } else if (quotaExhausted) {
            reason = "এই মাসের মাসিক কোটা (" + formatLiters(quota) + " লি.) ইতিমধ্যে সম্পূর্ণ ব্যবহৃত হয়েছে।";
        } else if (requestExceedsRemaining) {
            reason = "এই মাসে অবশিষ্ট সীমা মাত্র " + formatLiters(remaining)
                    + " লিটার। অনুরোধকৃত পরিমাণ এই সীমার বেশি।";
        }

        return new Result(eligible, reason, quota, eff.quotaOverridden(), usedThisMonth, remaining,
                lastSuccessAt, nextEligibleAt, cooldownHours, eff.cooldownOverridden(),
                eff.globalMonthlyQuotaLiters(), eff.globalCooldownHours());
    }

    /**
     * One-stop helper that returns formatted Bengali display strings for any UI surface
     * (admin vehicle detail, operator verify, user dashboard sidebar). All callers should
     * use this so the wording stays consistent. The underlying {@link Result} is exposed
     * under the {@code "raw"} key when callers need numeric values.
     */
    @Transactional(readOnly = true)
    public Map<String, Object> buildDisplay(Long vehicleId) {
        Result r = check(vehicleId);
        Map<String, Object> m = new HashMap<>();
        m.put("raw", r);
        m.put("eligibleNow", r.eligible());
        m.put("eligibilityReason", r.reason());
        m.put("lastRefueledDisplay", r.lastSuccessAt() == null
                ? "এখনো কোনো রিফুয়েলিং নেই"
                : BanglaDateTime.formatRelativeDay(r.lastSuccessAt()));
        m.put("nextEligibleDisplay", r.eligible()
                ? "এখনই উপলব্ধ"
                : (r.nextEligibleAt() != null
                        ? BanglaDateTime.formatRelativeDay(r.nextEligibleAt())
                        : "এই মাসে অনুপলব্ধ"));

        m.put("monthlyQuotaDisplay", formatLitersShort(r.monthlyQuotaLiters()));
        m.put("monthlyUsedDisplay", formatLitersShort(r.usedThisMonthLiters()));
        m.put("monthlyRemainingDisplay", formatLitersShort(r.remainingThisMonthLiters()));
        m.put("monthlyQuotaFullDisplay", formatLitersFull(r.monthlyQuotaLiters()));
        m.put("monthlyUsedFullDisplay", formatLitersFull(r.usedThisMonthLiters()));
        m.put("monthlyRemainingFullDisplay", formatLitersFull(r.remainingThisMonthLiters()));
        m.put("cooldownDisplay", BanglaDigits.convert(String.valueOf(r.cooldownHours())) + " ঘণ্টা");
        m.put("quotaOverridden", r.quotaOverridden());
        m.put("cooldownOverridden", r.cooldownOverridden());
        m.put("globalMonthlyQuotaDisplay", formatLitersShort(r.globalMonthlyQuotaLiters()));
        m.put("globalCooldownDisplay",
                BanglaDigits.convert(String.valueOf(r.globalCooldownHours())) + " ঘণ্টা");

        int percentUsed = computePercentUsed(r.usedThisMonthLiters(), r.monthlyQuotaLiters());
        m.put("percentUsed", percentUsed);
        m.put("percentUsedDisplay", BanglaDigits.convert(String.valueOf(percentUsed)) + "%");

        boolean inCooldown = r.nextEligibleAt() != null && Instant.now().isBefore(r.nextEligibleAt());
        boolean quotaExhausted = r.remainingThisMonthLiters().signum() == 0;
        String badgeLabel;
        if (r.eligible()) badgeLabel = "যোগ্য";
        else if (quotaExhausted) badgeLabel = "কোটা শেষ";
        else if (inCooldown) badgeLabel = "অপেক্ষমান";
        else badgeLabel = "অযোগ্য";
        m.put("badgeLabel", badgeLabel);
        m.put("badgeClass", r.eligible()
                ? "bg-emerald-50 text-emerald-700 border-emerald-200"
                : "bg-amber-50 text-amber-700 border-amber-200");
        return m;
    }

    private static int computePercentUsed(BigDecimal used, BigDecimal quota) {
        if (quota == null || quota.signum() <= 0) return 0;
        return used.multiply(BigDecimal.valueOf(100))
                .divide(quota, 0, RoundingMode.HALF_UP)
                .min(BigDecimal.valueOf(100))
                .intValueExact();
    }

    private static String formatLitersShort(BigDecimal v) {
        return formatLitersNumber(v) + " লি.";
    }

    private static String formatLitersFull(BigDecimal v) {
        return formatLitersNumber(v) + " লিটার";
    }

    private static String formatLitersNumber(BigDecimal v) {
        if (v == null) return "০";
        return BanglaDigits.convert(v.setScale(2, RoundingMode.HALF_UP).toPlainString());
    }

    private static String formatLiters(BigDecimal v) {
        if (v == null) return "—";
        return BanglaDigits.convert(v.setScale(2, RoundingMode.HALF_UP).toPlainString());
    }

    public record Effective(
            BigDecimal monthlyQuotaLiters,
            boolean quotaOverridden,
            int cooldownHours,
            boolean cooldownOverridden,
            BigDecimal globalMonthlyQuotaLiters,
            int globalCooldownHours
    ) {}

    public record Result(
            boolean eligible,
            String reason,
            BigDecimal monthlyQuotaLiters,
            boolean quotaOverridden,
            BigDecimal usedThisMonthLiters,
            BigDecimal remainingThisMonthLiters,
            Instant lastSuccessAt,
            Instant nextEligibleAt,
            int cooldownHours,
            boolean cooldownOverridden,
            BigDecimal globalMonthlyQuotaLiters,
            int globalCooldownHours
    ) {}
}

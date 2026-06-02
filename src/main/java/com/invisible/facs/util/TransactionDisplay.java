package com.invisible.facs.util;

import com.invisible.facs.model.TransactionStatus;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Shared formatting/badge helpers for transaction and vehicle display values.
 * Per-role status label wording differs (operator says "প্রত্যাখ্যাত", admin/user say "বাতিল"),
 * so we keep label resolution at the call site.
 */
public final class TransactionDisplay {

    private TransactionDisplay() {}

    public static String formatLitersShort(BigDecimal liters) {
        if (liters == null) return "—";
        return BanglaDigits.convert(liters.setScale(2, RoundingMode.HALF_UP).toPlainString()) + " L";
    }

    public static String statusBadgeClass(TransactionStatus status) {
        if (status == null) return "bg-gray-100 text-gray-700";
        return switch (status) {
            case SUCCESS -> "bg-brand text-white";
            case PENDING -> "bg-amber-400 text-amber-950";
            case CANCELLED -> "bg-brand-red text-white";
        };
    }

    public static String vehicleTypeLabel(String type) {
        if (type == null) return "—";
        return switch (type) {
            case "car" -> "কার";
            case "truck" -> "ট্রাক";
            case "bike" -> "বাইক";
            default -> type;
        };
    }
}

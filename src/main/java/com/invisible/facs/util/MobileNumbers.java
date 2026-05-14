package com.invisible.facs.util;

/**
 * Canonicalizes Bangladeshi mobile numbers. Storage / lookup form: {@code 8801XXXXXXXXX}.
 */
public final class MobileNumbers {

    private MobileNumbers() {}

    /**
     * Normalizes a Bangladeshi mobile number to 13 digits starting with "880".
     * Accepts forms like "01712345678", "+8801712345678", "8801712345678", "1712345678".
     * Returns {@code null} for null or any input that doesn't match one of these forms — callers
     * must null-check before using the result.
     */
    public static String normalize(String raw) {
        if (raw == null) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880") && digits.length() == 13) return digits;
        if (digits.startsWith("0") && digits.length() == 11) return "88" + digits;
        if (digits.startsWith("1") && digits.length() == 10) return "880" + digits;
        return null;
    }
}

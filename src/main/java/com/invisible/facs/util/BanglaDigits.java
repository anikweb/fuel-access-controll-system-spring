package com.invisible.facs.util;

public final class BanglaDigits {

    private BanglaDigits() {}

    public static String convert(String s) {
        if (s == null) return "";
        StringBuilder out = new StringBuilder(s.length());
        for (char c : s.toCharArray()) {
            if (c >= '0' && c <= '9') {
                out.append((char) ('০' + (c - '0')));
            } else {
                out.append(c);
            }
        }
        return out.toString();
    }

    /**
     * Mask a Bangladeshi mobile number for display, e.g.
     *   "01713456789" -> "+৮৮০ ১৭১৩-XXXXXX"
     */
    public static String maskMobile(String raw) {
        if (raw == null) return "+৮৮০ XXXXXXXXXX";
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880")) digits = digits.substring(3);
        if (digits.startsWith("0")) digits = digits.substring(1);
        if (digits.length() < 4) return "+৮৮০ XXXXXXXXXX";
        return "+" + convert("880 " + digits.substring(0, 4)) + "-XXXXXX";
    }

    /**
     * Format a Bangladeshi mobile for display without masking, e.g.
     *   "01712345678" -> "+৮৮০ ১৭১২-৩৪৫৬৭৮"
     * Falls back to converting input digits to Bangla if the shape is unexpected.
     */
    public static String formatMobile(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880")) digits = digits.substring(3);
        if (digits.startsWith("0")) digits = digits.substring(1);
        if (digits.length() != 10) return convert(raw);
        return "+" + convert("880 " + digits.substring(0, 4) + "-" + digits.substring(4));
    }

    /**
     * Partially masks a Bangladeshi mobile keeping the first 2 digits after the operator prefix and last 3
     * visible, e.g. "01712345402" -> "+৮৮০ ১৭** *** ৪০২".
     */
    public static String maskMobilePartial(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880")) digits = digits.substring(3);
        if (digits.startsWith("0")) digits = digits.substring(1);
        if (digits.length() != 10) return convert(raw);
        String head = convert(digits.substring(0, 2));
        String tail = convert(digits.substring(digits.length() - 3));
        return "+" + convert("880") + " " + head + "** *** " + tail;
    }

    /**
     * Masks a license/ID number keeping only the last 4 characters visible, e.g.
     *   "DH123456789830" -> "**** **** ৯৮৩০",
     *   "BLHAKJSBFKJSBF" -> "**** **** JSBF".
     */
    public static String maskLicense(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String trimmed = raw.trim();
        if (trimmed.length() <= 4) return "**** **** " + convert(trimmed);
        return "**** **** " + convert(trimmed.substring(trimmed.length() - 4));
    }
}

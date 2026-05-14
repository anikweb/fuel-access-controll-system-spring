package com.invisible.facs.util;

/**
 * Canonicalizes Bangladeshi mobile numbers. Storage / lookup form: {@code 8801XXXXXXXXX}.
 */
public final class MobileNumbers {

    private MobileNumbers() {}

    /** Returns null on null input; otherwise strips non-digits, prepends 880 if missing, returns 13-char digits. */
    public static String normalize(String raw) {
        if (raw == null) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880") && digits.length() == 13) return digits;
        if (digits.startsWith("0") && digits.length() == 11) return "88" + digits;
        if (digits.startsWith("1") && digits.length() == 10) return "880" + digits;
        return digits;
    }
}

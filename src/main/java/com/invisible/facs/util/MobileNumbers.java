package com.invisible.facs.util;

public final class MobileNumbers {

    private MobileNumbers() {}
    public static String normalize(String raw) {
        if (raw == null) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880") && digits.length() == 13) return digits;
        if (digits.startsWith("0") && digits.length() == 11) return "88" + digits;
        if (digits.startsWith("1") && digits.length() == 10) return "880" + digits;
        return null;
    }
}

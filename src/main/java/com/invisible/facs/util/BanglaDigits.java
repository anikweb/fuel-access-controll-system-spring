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
    public static String maskMobile(String raw) {
        if (raw == null) return "+৮৮০ XXXXXXXXXX";
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880")) digits = digits.substring(3);
        if (digits.startsWith("0")) digits = digits.substring(1);
        if (digits.length() < 4) return "+৮৮০ XXXXXXXXXX";
        return "+" + convert("880 " + digits.substring(0, 4)) + "-XXXXXX";
    }

    public static String formatMobile(String raw) {
        if (raw == null || raw.isBlank()) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.startsWith("880")) digits = digits.substring(3);
        if (digits.startsWith("0")) digits = digits.substring(1);
        if (digits.length() != 10) return convert(raw);
        return "+" + convert("880 " + digits.substring(0, 4) + "-" + digits.substring(4));
    }
}

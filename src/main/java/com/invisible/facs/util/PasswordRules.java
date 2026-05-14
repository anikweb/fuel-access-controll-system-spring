package com.invisible.facs.util;

public final class PasswordRules {

    public static final int MIN_LENGTH = 8;
    public static final int MAX_LENGTH = 100;
    public static final String PATTERN_REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$";

    public static final String LENGTH_MESSAGE = "পাসওয়ার্ড কমপক্ষে ৮ অক্ষর হতে হবে";
    public static final String PATTERN_MESSAGE =
            "পাসওয়ার্ডে কমপক্ষে একটি বড় হাতের অক্ষর, একটি ছোট হাতের অক্ষর ও একটি সংখ্যা থাকতে হবে";

    private PasswordRules() {}

    public static boolean isValid(String password) {
        if (password == null) return false;
        if (password.length() < MIN_LENGTH || password.length() > MAX_LENGTH) return false;
        return password.matches(PATTERN_REGEX);
    }
}

package com.invisible.facs.util;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;

public final class BanglaDateTime {

    public static final ZoneId DHAKA_ZONE = ZoneId.of("Asia/Dhaka");

    public static final String[] BANGLA_MONTHS = {
            "জানুয়ারি", "ফেব্রুয়ারি", "মার্চ", "এপ্রিল", "মে", "জুন",
            "জুলাই", "আগস্ট", "সেপ্টেম্বর", "অক্টোবর", "নভেম্বর", "ডিসেম্বর"
    };

    private BanglaDateTime() {}

    public static String formatDate(Instant instant) {
        if (instant == null) return null;
        LocalDate date = instant.atZone(DHAKA_ZONE).toLocalDate();
        String day = BanglaDigits.convert(String.valueOf(date.getDayOfMonth()));
        String year = BanglaDigits.convert(String.valueOf(date.getYear()));
        return day + " " + BANGLA_MONTHS[date.getMonthValue() - 1] + ", " + year;
    }

    public static String formatTime(Instant instant) {
        if (instant == null) return "—";
        ZonedDateTime zdt = instant.atZone(DHAKA_ZONE);
        int hour = zdt.getHour();
        String ampm = hour < 12 ? "AM" : "PM";
        int hour12 = hour % 12 == 0 ? 12 : hour % 12;
        return BanglaDigits.convert(String.format("%02d:%02d", hour12, zdt.getMinute())) + " " + ampm;
    }

    public static String formatDateTime(Instant instant) {
        if (instant == null) return "—";
        return formatDate(instant) + " | " + formatTime(instant);
    }

    /**
     * Day-relative format: today/yesterday show the prefix word + time, anything older shows the full date.
     * Mirrors the Bengali phrasing the dashboards use (e.g. "আজ ০৪:৩০ PM").
     */
    public static String formatRelativeDay(Instant instant) {
        if (instant == null) return "—";
        LocalDate target = instant.atZone(DHAKA_ZONE).toLocalDate();
        LocalDate today = LocalDate.now(DHAKA_ZONE);
        if (target.equals(today)) {
            return "আজ " + formatTime(instant);
        }
        if (target.equals(today.minusDays(1))) {
            return "গতকাল " + formatTime(instant);
        }
        return formatDateTime(instant);
    }
}


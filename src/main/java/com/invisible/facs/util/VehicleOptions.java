package com.invisible.facs.util;

import java.util.List;

/**
 * Predefined option lists shown in the vehicle signup step. Kept here (not in the DB) because
 * the lists are small, mostly stable, and rendering them server-side keeps the UI offline-friendly.
 */
public final class VehicleOptions {

    public static final List<String> BRANDS = List.of(
            "টয়োটা (Toyota)",
            "হোন্ডা (Honda)",
            "নিসান (Nissan)",
            "মিৎসুবিশি (Mitsubishi)",
            "হুন্ডাই (Hyundai)",
            "কিয়া (Kia)",
            "সুজুকি (Suzuki)",
            "টাটা (Tata)",
            "মাহিন্দ্রা (Mahindra)",
            "ফোর্ড (Ford)",
            "বাজাজ (Bajaj)",
            "ইয়ামাহা (Yamaha)",
            "হিরো (Hero)",
            "টিভিএস (TVS)",
            "অন্যান্য (Other)");

    public static final List<VehicleTypeOption> TYPES = List.of(
            new VehicleTypeOption("কার", "car"),
            new VehicleTypeOption("ট্রাক", "truck"),
            new VehicleTypeOption("বাইক", "bike"));

    public record VehicleTypeOption(String label, String icon) {}

    private VehicleOptions() {}
}

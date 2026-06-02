package com.invisible.facs.service;

import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

public interface PlateOcrService {

    /** Provider tag for UI display (e.g. "noop", "gemini:gemini-2.0-flash"). */
    String providerId();

    /** Whether this provider can actually perform OCR. */
    boolean enabled();

    /** Returns the extracted plate text, or empty if none / not recognized / OCR failed. */
    Optional<String> extractPlate(MultipartFile image);
}

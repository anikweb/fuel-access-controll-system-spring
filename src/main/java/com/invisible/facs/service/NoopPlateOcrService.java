package com.invisible.facs.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@Slf4j
public class NoopPlateOcrService implements PlateOcrService {

    @Override
    public String providerId() {
        return "noop";
    }

    @Override
    public boolean enabled() {
        return false;
    }

    @Override
    public Optional<String> extractPlate(MultipartFile image) {
        return Optional.empty();
    }
}

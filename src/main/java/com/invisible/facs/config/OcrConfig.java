package com.invisible.facs.config;

import com.invisible.facs.service.GeminiPlateOcrService;
import com.invisible.facs.service.NoopPlateOcrService;
import com.invisible.facs.service.PlateOcrService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;
import tools.jackson.databind.ObjectMapper;

@Slf4j
@Configuration
public class OcrConfig {

    @Bean
    public RestClient ocrRestClient() {
        return RestClient.builder().build();
    }

    @Bean
    public PlateOcrService plateOcrService(OcrProperties props,
                                           RestClient ocrRestClient,
                                           ObjectMapper objectMapper) {
        if ("gemini".equalsIgnoreCase(props.getProvider())) {
            if (props.getApiKey() == null || props.getApiKey().isBlank()) {
                log.warn("facs.ocr.provider=gemini but facs.ocr.api-key is missing — disabling OCR.");
                return new NoopPlateOcrService();
            }
            if (props.getModel() == null || props.getModel().isBlank()) {
                log.warn("facs.ocr.provider=gemini but facs.ocr.model is missing — disabling OCR.");
                return new NoopPlateOcrService();
            }
            log.info("OCR provider: gemini ({})", props.getModel());
            return new GeminiPlateOcrService(props, ocrRestClient, objectMapper);
        }
        log.info("OCR provider: noop (image OCR disabled)");
        return new NoopPlateOcrService();
    }
}

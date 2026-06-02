package com.invisible.facs.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "facs.ocr")
public class OcrProperties {

    /** "noop" (default) or "gemini". */
    private String provider = "gemini";

    private String apiKey;

    /** Gemini model name, e.g. "gemini-2.0-flash" or "gemini-2.5-flash". */
    private String model = "gemini-2.5-flash";

    private String baseUrl = "https://generativelanguage.googleapis.com/v1beta";
}

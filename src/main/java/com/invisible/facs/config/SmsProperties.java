package com.invisible.facs.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "facs.sms")
public class SmsProperties {

    /** "console" (default) or "bulksmsbd". */
    private String provider = "console";

    private String apiKey;

    private String senderId;

    private String baseUrl = "https://bulksmsbd.net/api/smsapi";

    /**
     * Message type passed to the provider as the {@code type} query param (e.g.
     * "text").
     */
    private String type = "text";
}

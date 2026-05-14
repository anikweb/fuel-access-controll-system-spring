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
}

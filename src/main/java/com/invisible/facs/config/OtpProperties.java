package com.invisible.facs.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "facs.otp")
public class OtpProperties {
    private int length = 6;
    private int expirySeconds = 300;
}

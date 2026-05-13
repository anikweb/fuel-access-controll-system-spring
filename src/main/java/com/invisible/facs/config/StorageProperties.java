package com.invisible.facs.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "facs.uploads")
public class StorageProperties {
    private String dir = "./uploads";
    private String urlPrefix = "/uploads";
}

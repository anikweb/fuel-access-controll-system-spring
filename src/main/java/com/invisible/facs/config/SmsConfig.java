package com.invisible.facs.config;

import com.invisible.facs.service.BulkSmsBdSender;
import com.invisible.facs.service.ConsoleSmsSender;
import com.invisible.facs.service.SmsSender;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Slf4j
@Configuration
public class SmsConfig {

    @Bean
    public RestClient smsRestClient() {
        return RestClient.builder().build();
    }

    @Bean
    public SmsSender smsSender(SmsProperties props, RestClient smsRestClient) {
        if ("bulksmsbd".equalsIgnoreCase(props.getProvider())) {
            if (props.getApiKey() == null || props.getApiKey().isBlank()
                    || props.getSenderId() == null || props.getSenderId().isBlank()) {
                throw new IllegalStateException(
                        "facs.sms.provider=bulksmsbd requires facs.sms.api-key and facs.sms.sender-id");
            }
            log.info("SMS provider: bulksmsbd ({})", props.getBaseUrl());
            return new BulkSmsBdSender(props, smsRestClient);
        }
        log.info("SMS provider: console (dev mode — OTP codes will be logged)");
        return new ConsoleSmsSender();
    }
}

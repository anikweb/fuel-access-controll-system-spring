package com.invisible.facs.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.invisible.facs.config.SmsProperties;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.MobileNumbers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

@Slf4j
@RequiredArgsConstructor
public class BulkSmsBdSender implements SmsSender {

    private static final int SUCCESS_CODE = 202;

    private final SmsProperties properties;
    private final RestClient restClient;

    @Override
    public void send(String mobile, String message) {
        String number = MobileNumbers.normalize(mobile);

        URI uri = UriComponentsBuilder.fromUriString(properties.getBaseUrl())
                .queryParam("api_key", properties.getApiKey())
                .queryParam("type", "text")
                .queryParam("number", number)
                .queryParam("senderid", properties.getSenderId())
                .queryParam("message", message)
                .build()
                .encode()
                .toUri();

        BulkSmsResponse response;
        try {
            response = restClient.get()
                    .uri(uri)
                    .retrieve()
                    .body(BulkSmsResponse.class);
        } catch (RuntimeException e) {
            log.error("SMS send failed for {}: {}", BanglaDigits.maskMobile(number), e.getMessage());
            throw new RuntimeException("SMS send failed", e);
        }

        int code = (response == null) ? -1 : response.responseCode();
        if (code == SUCCESS_CODE) {
            log.info("Sent SMS to {} via bulksmsbd", BanglaDigits.maskMobile(number));
            return;
        }
        log.error("bulksmsbd refused SMS to {} (code={})", BanglaDigits.maskMobile(number), code);
        throw new RuntimeException("SMS send failed: provider code=" + code);
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record BulkSmsResponse(@JsonProperty("response_code") int responseCode) {}
}

package com.invisible.facs.service;

import com.invisible.facs.config.SmsProperties;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.MobileNumbers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@RequiredArgsConstructor
public class BulkSmsBdSender implements SmsSender {

    private static final Pattern RESPONSE_CODE = Pattern.compile("\"response_code\"\\s*:\\s*(\\d+)");

    private final SmsProperties properties;
    private final RestClient restClient;

    @Override
    public void send(String mobile, String message) {
        String number = MobileNumbers.normalize(mobile);

        URI uri = UriComponentsBuilder.fromUriString(properties.getBaseUrl())
                .queryParam("api_key", properties.getApiKey())
                .queryParam("type", properties.getType())
                .queryParam("number", number)
                .queryParam("senderid", properties.getSenderId())
                .queryParam("message", message)
                .build()
                .encode()
                .toUri();

        String body;
        try {
            body = restClient.get()
                    .uri(uri)
                    .retrieve()
                    .body(String.class);
        } catch (RestClientException e) {
            log.error("SMS send failed for {}: {}", BanglaDigits.maskMobile(number), e.getMessage());
            throw new RuntimeException("SMS send failed", e);
        }

        int code = parseResponseCode(body);
        if (code == 202) {
            log.info("Sent SMS to {} via bulksmsbd", BanglaDigits.maskMobile(number));
            return;
        }
        log.error("bulksmsbd refused SMS to {} (code={})", BanglaDigits.maskMobile(number), code);
        throw new RuntimeException("SMS send failed: provider code=" + code);
    }

    private static int parseResponseCode(String body) {
        if (body == null) return -1;
        Matcher m = RESPONSE_CODE.matcher(body);
        if (!m.find()) return -1;
        try {
            return Integer.parseInt(m.group(1));
        } catch (NumberFormatException e) {
            return -1;
        }
    }
}

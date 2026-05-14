package com.invisible.facs.service;

import com.invisible.facs.util.BanglaDigits;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ConsoleSmsSender implements SmsSender {

    @Override
    public void send(String mobile, String message) {
        log.info("[SMS to {}] message length={} chars (code redacted)",
                BanglaDigits.maskMobile(mobile), message.length());
    }
}

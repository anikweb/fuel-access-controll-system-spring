package com.invisible.facs.service;

public interface SmsSender {

    /**
     * Sends an SMS. Throws RuntimeException if the provider refuses or the request fails.
     */
    void send(String mobile, String message);
}

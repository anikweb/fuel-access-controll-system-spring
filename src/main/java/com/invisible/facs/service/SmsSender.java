package com.invisible.facs.service;

public interface SmsSender {
    void send(String mobile, String message);
}

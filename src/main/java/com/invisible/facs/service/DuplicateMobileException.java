package com.invisible.facs.service;

/**
 * Thrown when a registration tries to finalize for a mobile number that has already
 * been claimed (e.g. another user signed up with the same number between the
 * security step and OTP verification).
 */
public class DuplicateMobileException extends RuntimeException {

    public DuplicateMobileException(String mobile) {
        super("Account already exists for mobile: " + mobile);
    }
}

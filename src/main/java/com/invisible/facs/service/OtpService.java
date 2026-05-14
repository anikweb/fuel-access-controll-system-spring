package com.invisible.facs.service;

import com.invisible.facs.config.OtpProperties;
import com.invisible.facs.model.OtpChallenge;
import com.invisible.facs.model.OtpPurpose;
import com.invisible.facs.repository.OtpChallengeRepository;
import com.invisible.facs.util.MobileNumbers;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Optional;

@Slf4j
@Service
@EnableConfigurationProperties(OtpProperties.class)
public class OtpService {

    private static final SecureRandom RANDOM = new SecureRandom();

    @Autowired
    private OtpChallengeRepository repository;

    @Autowired
    private SmsSender smsSender;

    @Autowired
    private OtpProperties properties;

    @Transactional
    public void issue(String mobile, OtpPurpose purpose) {
        String normalized = MobileNumbers.normalize(mobile);
        if (normalized == null || normalized.isBlank()) {
            throw new IllegalArgumentException("Mobile is required to issue an OTP");
        }
        Instant now = Instant.now();
        String code = generateCode();

        OtpChallenge challenge = OtpChallenge.builder()
                .mobile(normalized)
                .purpose(purpose)
                .codeHash(code)
                .expiresAt(now.plusSeconds(properties.getExpirySeconds()))
                .build();
        repository.save(challenge);

        int minutes = Math.max(1, properties.getExpirySeconds() / 60);
        String message = "Your FACS verification code is " + code
                + ". Valid for " + minutes + " min. Do not share.";
        smsSender.send(normalized, message);
    }

    @Transactional
    public boolean verify(String mobile, OtpPurpose purpose, String code) {
        String normalized = MobileNumbers.normalize(mobile);
        if (normalized == null || code == null || !code.matches("\\d+")) return false;

        Optional<OtpChallenge> challengeOpt =
                repository.findTopByMobileAndPurposeOrderByCreatedAtDesc(normalized, purpose);
        if (challengeOpt.isEmpty()) return false;

        OtpChallenge challenge = challengeOpt.get();
        Instant now = Instant.now();

        if (challenge.getConsumedAt() != null) return false;
        if (challenge.getExpiresAt().isBefore(now)) return false;

        if (code.equals(challenge.getCodeHash())) {
            challenge.setConsumedAt(now);
            repository.save(challenge);
            return true;
        }
        return false;
    }

    private String generateCode() {
        int max = (int) Math.pow(10, properties.getLength());
        int value = RANDOM.nextInt(max);
        return String.format("%0" + properties.getLength() + "d", value);
    }
}

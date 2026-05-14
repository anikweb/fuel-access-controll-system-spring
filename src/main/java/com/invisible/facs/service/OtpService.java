package com.invisible.facs.service;

import com.invisible.facs.config.OtpProperties;
import com.invisible.facs.model.OtpChallenge;
import com.invisible.facs.model.OtpPurpose;
import com.invisible.facs.repository.OtpChallengeRepository;
import com.invisible.facs.util.MobileNumbers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final OtpChallengeRepository repository;
    private final SmsSender smsSender;
    private final OtpProperties properties;

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
                .code(code)
                .expiresAt(now.plusSeconds(properties.getExpirySeconds()))
                .build();
        repository.save(challenge);

        int minutes = Math.max(1, properties.getExpirySeconds() / 60);
        String message = "আপনার FACS ভেরিফিকেশন কোড হলো " + code
                + ",  মেয়াদঃ " + minutes + " মিনিট";
        smsSender.send(normalized, message);
    }

    @Transactional
    public boolean verify(String mobile, OtpPurpose purpose, String code) {
        String normalized = MobileNumbers.normalize(mobile);
        if (normalized == null || code == null
                || code.length() != properties.getLength() || !code.matches("\\d+")) {
            return false;
        }

        Optional<OtpChallenge> challengeOpt =
                repository.findTopByMobileAndPurposeOrderByCreatedAtDesc(normalized, purpose);
        if (challengeOpt.isEmpty()) return false;

        OtpChallenge challenge = challengeOpt.get();
        Instant now = Instant.now();

        if (challenge.getConsumedAt() != null) return false;
        if (challenge.getExpiresAt().isBefore(now)) return false;
        if (challenge.getAttempts() >= properties.getMaxAttempts()) return false;

        challenge.setAttempts(challenge.getAttempts() + 1);

        if (code.equals(challenge.getCode())) {
            challenge.setConsumedAt(now);
            repository.save(challenge);
            return true;
        }
        repository.save(challenge);
        return false;
    }

    private String generateCode() {
        int max = (int) Math.pow(10, properties.getLength());
        int value = RANDOM.nextInt(max);
        return String.format("%0" + properties.getLength() + "d", value);
    }
}

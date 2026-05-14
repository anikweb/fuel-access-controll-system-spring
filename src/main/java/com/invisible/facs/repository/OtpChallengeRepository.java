package com.invisible.facs.repository;

import com.invisible.facs.model.OtpChallenge;
import com.invisible.facs.model.OtpPurpose;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OtpChallengeRepository extends JpaRepository<OtpChallenge, Long> {

    Optional<OtpChallenge> findTopByMobileAndPurposeOrderByCreatedAtDesc(String mobile, OtpPurpose purpose);
}

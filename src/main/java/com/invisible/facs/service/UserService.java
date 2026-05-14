package com.invisible.facs.service;

import com.invisible.facs.model.OtpPurpose;
import com.invisible.facs.model.User;
import com.invisible.facs.model.UserProfile;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.MobileNumbers;
import com.invisible.facs.util.PasswordRules;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.VehicleRepository;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;

import java.security.Principal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private static final String S_MOBILE = "resetMobile";
    private static final String S_VERIFIED = "resetVerified";

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final PasswordEncoder passwordEncoder;
    private final OtpService otpService;

    @Transactional(readOnly = true)
    public String prepareDashboard(Principal principal, Model model) {
        if (principal == null) {
            return "redirect:/";
        }
        String mobile = principal.getName();
        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) {
            return "redirect:/";
        }
        User user = userOpt.get();

        UserProfile profile = user.getProfile();
        List<Vehicle> vehicles = vehicleRepository.findByUserIdOrderByCreatedAtDesc(user.getId());

        Map<String, Object> profileCard = null;
        if (profile != null) {
            profileCard = new HashMap<>();
            profileCard.put("photoUrl", profile.getPhotoPath());
            profileCard.put("name", profile.getName());
            profileCard.put("nidNumber", profile.getNidNumber());
            profileCard.put("licenseNumber", profile.getLicenseNumber());
            profileCard.put("district", profile.getDistrict());
            profileCard.put("subDistrict", profile.getSubDistrict());
            profileCard.put("address", profile.getAddress());
            profileCard.put("licenseFrontUrl", profile.getLicenseFrontPath());
            profileCard.put("licenseBackUrl", profile.getLicenseBackPath());
        }

        List<Map<String, String>> vehicleCards = new ArrayList<>();
        for (Vehicle v : vehicles) {
            Map<String, String> card = new HashMap<>();
            card.put("plateNumber", v.getPlateNumber());
            card.put("brand", v.getBrand());
            card.put("model", v.getModel());
            card.put("type", v.getVehicleType());
            card.put("color", v.getColor());
            card.put("year", v.getManufactureYear());
            card.put("plateImageUrl", v.getPlateImagePath());
            vehicleCards.add(card);
        }

        String displayName;
        if (profile != null && profile.getName() != null && !profile.getName().isBlank()) {
            displayName = profile.getName();
        } else if (user.getName() != null) {
            displayName = user.getName();
        } else {
            displayName = user.getMobile();
        }

        Map<String, Object> view = new HashMap<>();
        view.put("displayName", displayName);
        view.put("mobile", BanglaDigits.formatMobile(user.getMobile()));
        view.put("profile", profileCard);
        view.put("vehicles", vehicleCards);

        model.addAttribute("view", view);
        return "user/dashboard";
    }

    public String requestPasswordReset(String rawMobile, HttpSession session) {
        String mobile = MobileNumbers.normalize(rawMobile);

        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) {
            return "redirect:/forgot-password?error=notFound";
        }

        session.setAttribute(S_MOBILE, mobile);
        session.removeAttribute(S_VERIFIED);
        try {
            otpService.issue(mobile, OtpPurpose.PASSWORD_RESET);
        } catch (RuntimeException e) {
            log.warn("Password-reset OTP send failed: {}", e.getMessage());
            return "redirect:/forgot-password?smsError=generic";
        }
        return "redirect:/verify-otp";
    }

    public String verifyResetOtp(String code, HttpSession session) {
        String mobile = (String) session.getAttribute(S_MOBILE);
        if (mobile == null) return "redirect:/forgot-password";

        if (!otpService.verify(mobile, OtpPurpose.PASSWORD_RESET, code)) {
            return "redirect:/verify-otp?error";
        }
        session.setAttribute(S_VERIFIED, Boolean.TRUE);
        return "redirect:/reset-password";
    }

    public String resendResetOtp(HttpSession session) {
        String mobile = (String) session.getAttribute(S_MOBILE);
        if (mobile == null) return "redirect:/forgot-password";
        try {
            otpService.issue(mobile, OtpPurpose.PASSWORD_RESET);
        } catch (RuntimeException e) {
            log.warn("Password-reset OTP resend failed: {}", e.getMessage());
            return "redirect:/verify-otp?smsError=generic";
        }
        return "redirect:/verify-otp?resent";
    }

    @Transactional
    public String submitNewPassword(String password, String passwordConfirm, HttpSession session) {
        if (!isResetVerified(session)) return "redirect:/forgot-password";

        if (!PasswordRules.isValid(password)) {
            return "redirect:/reset-password?error=weak";
        }
        if (!password.equals(passwordConfirm)) {
            return "redirect:/reset-password?error=mismatch";
        }

        String mobile = (String) session.getAttribute(S_MOBILE);
        Optional<User> userOpt = userRepository.findByMobile(mobile);
        if (userOpt.isEmpty()) {
            session.removeAttribute(S_MOBILE);
            session.removeAttribute(S_VERIFIED);
            return "redirect:/forgot-password";
        }
        User user = userOpt.get();
        user.setPasswordHash(passwordEncoder.encode(password));
        userRepository.save(user);

        session.invalidate();
        return "redirect:/?passwordReset";
    }

    public boolean isResetVerified(HttpSession session) {
        if (!Boolean.TRUE.equals(session.getAttribute(S_VERIFIED))) return false;
        if (session.getAttribute(S_MOBILE) == null) return false;
        return true;
    }

    public String getResetMobile(HttpSession session) {
        return (String) session.getAttribute(S_MOBILE);
    }
}

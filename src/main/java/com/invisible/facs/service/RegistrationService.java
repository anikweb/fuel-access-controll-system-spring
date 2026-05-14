package com.invisible.facs.service;

import com.invisible.facs.model.OtpPurpose;
import com.invisible.facs.model.PersonalInfoForm;
import com.invisible.facs.model.SecurityForm;
import com.invisible.facs.model.User;
import com.invisible.facs.model.UserProfile;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.util.BanglaDigits;
import com.invisible.facs.util.MobileNumbers;
import com.invisible.facs.model.Vehicle;
import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class RegistrationService {

    private static final String S_PERSONAL = "regPersonal";
    private static final String S_VEHICLE = "regVehicle";
    private static final String S_SECURITY = "regSecurity";
    private static final String S_OTP_SENT = "regOtpSent";

    private static final List<String> STEP_LABELS = new ArrayList<>();
    static {
        STEP_LABELS.add("ব্যক্তিগত তথ্য");
        STEP_LABELS.add("যানবাহনের তথ্য");
        STEP_LABELS.add("নিরাপত্তা");
        STEP_LABELS.add("রিভিউ");
    }

    public static final int STEP_PERSONAL = 0;
    public static final int STEP_VEHICLE = 1;
    public static final int STEP_SECURITY = 2;
    public static final int STEP_REVIEW = 3;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private FileStorageService fileStorageService;

    @Autowired
    private OtpService otpService;

    public void prepareCommonModel(HttpSession session, Model model, int currentIndex) {
        model.addAttribute("stepLabels", STEP_LABELS);
        model.addAttribute("currentIndex", currentIndex);
        model.addAttribute("draft", buildDraftMap(session));
        model.addAttribute("errors", new HashMap<String, String>());
    }

    public void prepareReviewModel(HttpSession session, Model model) {
        prepareCommonModel(session, model, STEP_REVIEW);
        PersonalInfoForm personal = getPersonal(session);
        Vehicle vehicle = getVehicle(session);
        SecurityForm security = getSecurity(session);

        model.addAttribute("displayMobile", BanglaDigits.formatMobile(security.getMobile()));
        model.addAttribute("displayVehicleType", vehicle.getVehicleType());
        model.addAttribute("displayBrand", vehicle.getBrand());
        model.addAttribute("displayDistrict", personal.getDistrict());
        model.addAttribute("displaySubDistrict", personal.getSubDistrict());
        model.addAttribute("displayModelYear", formatModelYear(vehicle));
    }

    public String submitPersonal(PersonalInfoForm form, BindingResult bindingResult,
                                 MultipartFile photo, MultipartFile licenseFront, MultipartFile licenseBack,
                                 HttpSession session, Model model) {
        prepareCommonModel(session, model, STEP_PERSONAL);
        if (bindingResult.hasErrors()) {
            model.addAttribute("errors", errorMap(bindingResult));
            return "signup/step-personal";
        }
        PersonalInfoForm existing = getPersonal(session);
        try {
            String photoPath = fileStorageService.store(photo, "users/photos");
            String frontPath = fileStorageService.store(licenseFront, "users/licenses");
            String backPath = fileStorageService.store(licenseBack, "users/licenses");
            if (photoPath != null) fileStorageService.delete(existing.getPhotoRef());
            if (frontPath != null) fileStorageService.delete(existing.getLicenseFrontRef());
            if (backPath != null) fileStorageService.delete(existing.getLicenseBackRef());
            form.setPhotoRef(photoPath != null ? photoPath : existing.getPhotoRef());
            form.setLicenseFrontRef(frontPath != null ? frontPath : existing.getLicenseFrontRef());
            form.setLicenseBackRef(backPath != null ? backPath : existing.getLicenseBackRef());
        } catch (IllegalArgumentException e) {
            model.addAttribute("uploadError", e.getMessage());
            return "signup/step-personal";
        }
        session.setAttribute(S_PERSONAL, form);
        return "redirect:/signup/vehicle";
    }

    public String submitVehicle(Vehicle form, BindingResult bindingResult,
                                MultipartFile plateImage,
                                HttpSession session, Model model) {
        prepareCommonModel(session, model, STEP_VEHICLE);
        if (bindingResult.hasErrors()) {
            model.addAttribute("errors", errorMap(bindingResult));
            return "signup/step-vehicle";
        }
        Vehicle existing = getVehicle(session);
        try {
            String platePath = fileStorageService.store(plateImage, "users/plates");
            if (platePath != null) fileStorageService.delete(existing.getPlateImageRef());
            form.setPlateImageRef(platePath != null ? platePath : existing.getPlateImageRef());
        } catch (IllegalArgumentException e) {
            model.addAttribute("uploadError", e.getMessage());
            return "signup/step-vehicle";
        }
        session.setAttribute(S_VEHICLE, form);
        return "redirect:/signup/security";
    }

    public String submitSecurity(SecurityForm form, BindingResult bindingResult,
                                 HttpSession session, Model model) {
        prepareCommonModel(session, model, STEP_SECURITY);
        if (!form.getPassword().equals(form.getPasswordConfirm())) {
            bindingResult.rejectValue("passwordConfirm", "mismatch", "পাসওয়ার্ড মিলছে না");
        }
        if (bindingResult.hasErrors()) {
            model.addAttribute("errors", errorMap(bindingResult));
            return "signup/step-security";
        }
        String normalized = MobileNumbers.normalize(form.getMobile());
        if (userRepository.findByMobile(normalized).isPresent()) {
            bindingResult.rejectValue("mobile", "duplicate",
                    "এই মোবাইল নম্বর দিয়ে ইতিমধ্যে একটি অ্যাকাউন্ট রয়েছে।");
            model.addAttribute("errors", errorMap(bindingResult));
            return "signup/step-security";
        }
        form.setMobile(normalized);
        session.setAttribute(S_SECURITY, form);
        session.setAttribute(S_OTP_SENT, Boolean.FALSE);
        return "redirect:/signup/review";
    }

    public String submitReview(String confirmDeclaration, HttpSession session) {
        if (confirmDeclaration == null) {
            return "redirect:/signup/review?error=declaration";
        }
        SecurityForm security = getSecurity(session);
        String mobile = security.getMobile();
        if (mobile == null || mobile.isBlank()) {
            return "redirect:/signup/security";
        }
        try {
            otpService.issue(mobile, OtpPurpose.SIGNUP);
        } catch (RuntimeException e) {
            log.warn("OTP send failed: {}", e.getMessage());
            return "redirect:/signup/review?smsError=generic";
        }
        session.setAttribute(S_OTP_SENT, Boolean.TRUE);
        return "redirect:/signup/verify-otp";
    }

    public boolean isOtpSent(HttpSession session) {
        return Boolean.TRUE.equals(session.getAttribute(S_OTP_SENT));
    }

    public String getCurrentMobile(HttpSession session) {
        SecurityForm security = (SecurityForm) session.getAttribute(S_SECURITY);
        return security == null ? null : security.getMobile();
    }

    public String verifyOtpAndFinalize(String code, HttpSession session) {
        if (!isOtpSent(session)) {
            return "redirect:/signup/review";
        }
        String mobile = getCurrentMobile(session);
        if (mobile == null || mobile.isBlank()) {
            return "redirect:/signup/security";
        }
        if (!otpService.verify(mobile, OtpPurpose.SIGNUP, code)) {
            return "redirect:/signup/verify-otp?error";
        }
        try {
            finalizeDraft(session);
            reset(session);
            return "redirect:/?registered";
        } catch (RuntimeException e) {
            log.warn("finalizeDraft failed: {}", e.getMessage());
            return "redirect:/signup/security?error=registrationFailed";
        }
    }

    public String resendOtp(HttpSession session) {
        if (!isOtpSent(session)) {
            return "redirect:/signup/review";
        }
        String mobile = getCurrentMobile(session);
        if (mobile == null || mobile.isBlank()) {
            return "redirect:/signup/security";
        }
        try {
            otpService.issue(mobile, OtpPurpose.SIGNUP);
            return "redirect:/signup/verify-otp?resent";
        } catch (RuntimeException e) {
            log.warn("OTP resend failed: {}", e.getMessage());
            return "redirect:/signup/verify-otp?smsError=generic";
        }
    }

    @Transactional
    public void finalizeDraft(HttpSession session) {
        PersonalInfoForm personal = getPersonal(session);
        Vehicle vehicle = getVehicle(session);
        SecurityForm security = getSecurity(session);

        if (security.getMobile() == null || security.getMobile().isBlank()
                || security.getPassword() == null || security.getPassword().isBlank()) {
            throw new IllegalStateException("Draft is incomplete; cannot finalize.");
        }

        String mobile = MobileNumbers.normalize(security.getMobile());
        if (userRepository.findByMobile(mobile).isPresent()) {
            throw new IllegalStateException("Account already exists for this mobile");
        }

        User user = User.builder()
                .mobile(mobile)
                .passwordHash(passwordEncoder.encode(security.getPassword()))
                .name(personal.getName())
                .build();

        UserProfile profile = UserProfile.builder()
                .user(user)
                .name(personal.getName())
                .licenseNumber(personal.getLicenseNumber())
                .nidNumber(personal.getNidNumber())
                .address(personal.getAddress())
                .districtCode(personal.getDistrict())
                .subDistrictCode(personal.getSubDistrict())
                .photoPath(personal.getPhotoRef())
                .licenseFrontPath(personal.getLicenseFrontRef())
                .licenseBackPath(personal.getLicenseBackRef())
                .build();
        user.setProfile(profile);

        vehicle.setUser(user);
        user.getVehicles().add(vehicle);

        User saved = userRepository.save(user);
        log.info("Registered user id={} mobile={}", saved.getId(), saved.getMobile());
    }

    public void reset(HttpSession session) {
        session.removeAttribute(S_PERSONAL);
        session.removeAttribute(S_VEHICLE);
        session.removeAttribute(S_SECURITY);
        session.removeAttribute(S_OTP_SENT);
    }

    private PersonalInfoForm getPersonal(HttpSession session) {
        PersonalInfoForm form = (PersonalInfoForm) session.getAttribute(S_PERSONAL);
        return form == null ? new PersonalInfoForm() : form;
    }

    private Vehicle getVehicle(HttpSession session) {
        Vehicle vehicle = (Vehicle) session.getAttribute(S_VEHICLE);
        return vehicle == null ? new Vehicle() : vehicle;
    }

    private SecurityForm getSecurity(HttpSession session) {
        SecurityForm form = (SecurityForm) session.getAttribute(S_SECURITY);
        return form == null ? new SecurityForm() : form;
    }

    private Map<String, Object> buildDraftMap(HttpSession session) {
        Map<String, Object> draft = new HashMap<>();
        draft.put("personal", getPersonal(session));
        draft.put("vehicle", getVehicle(session));
        draft.put("security", getSecurity(session));
        return draft;
    }

    private String formatModelYear(Vehicle v) {
        if (v.getModel() == null || v.getModel().isBlank()) return null;
        if (v.getManufactureYear() == null || v.getManufactureYear().isBlank()) return v.getModel();
        return v.getModel() + " - " + v.getManufactureYear();
    }

    private Map<String, String> errorMap(BindingResult bindingResult) {
        Map<String, String> errors = new HashMap<>();
        for (FieldError fe : bindingResult.getFieldErrors()) {
            if (!errors.containsKey(fe.getField())) {
                errors.put(fe.getField(), fe.getDefaultMessage());
            }
        }
        return errors;
    }
}

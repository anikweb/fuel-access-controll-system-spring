package com.invisible.facs.controller;

import com.invisible.facs.model.PersonalInfoForm;
import com.invisible.facs.model.SecurityForm;
import com.invisible.facs.model.Vehicle;
import com.invisible.facs.service.RegistrationService;
import com.invisible.facs.util.BanglaDigits;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

@Controller
@RequestMapping("/signup")
public class SignupController {

    @Autowired
    private RegistrationService registrationService;

    @GetMapping
    public String start() {
        return "redirect:/signup/personal";
    }

    @GetMapping("/personal")
    public String personal(HttpSession session, Model model) {
        registrationService.prepareCommonModel(session, model, RegistrationService.STEP_PERSONAL);
        return "signup/step-personal";
    }

    @PostMapping("/personal")
    public String submitPersonal(@Valid @ModelAttribute("form") PersonalInfoForm form,
                                 BindingResult bindingResult,
                                 @RequestParam(value = "photo", required = false) MultipartFile photo,
                                 @RequestParam(value = "licenseFront", required = false) MultipartFile licenseFront,
                                 @RequestParam(value = "licenseBack", required = false) MultipartFile licenseBack,
                                 HttpSession session, Model model) {
        return registrationService.submitPersonal(form, bindingResult, photo, licenseFront, licenseBack, session, model);
    }

    @GetMapping("/vehicle")
    public String vehicle(HttpSession session, Model model) {
        registrationService.prepareCommonModel(session, model, RegistrationService.STEP_VEHICLE);
        return "signup/step-vehicle";
    }

    @PostMapping("/vehicle")
    public String submitVehicle(@Valid @ModelAttribute("form") Vehicle form,
                                BindingResult bindingResult,
                                @RequestParam(value = "plateImage", required = false) MultipartFile plateImage,
                                HttpSession session, Model model) {
        return registrationService.submitVehicle(form, bindingResult, plateImage, session, model);
    }

    @GetMapping("/security")
    public String security(HttpSession session, Model model) {
        registrationService.prepareCommonModel(session, model, RegistrationService.STEP_SECURITY);
        return "signup/step-security";
    }

    @PostMapping("/security")
    public String submitSecurity(@Valid @ModelAttribute("form") SecurityForm form,
                                 BindingResult bindingResult,
                                 HttpSession session, Model model) {
        return registrationService.submitSecurity(form, bindingResult, session, model);
    }

    @GetMapping("/review")
    public String review(HttpSession session, Model model) {
        registrationService.prepareReviewModel(session, model);
        return "signup/step-review";
    }

    @PostMapping("/review")
    public String submitReview(@RequestParam(value = "confirmDeclaration", required = false) String confirmDeclaration,
                               HttpSession session) {
        return registrationService.submitReview(confirmDeclaration, session);
    }

    @GetMapping("/verify-otp")
    public String verifyOtpForm(HttpSession session, Model model) {
        if (!registrationService.isOtpSent(session)) {
            return "redirect:/signup/review";
        }
        String mobile = registrationService.getCurrentMobile(session);
        if (mobile == null || mobile.isBlank()) {
            return "redirect:/signup/security";
        }
        model.addAttribute("maskedMobile", BanglaDigits.formatMobile(mobile));
        model.addAttribute("verifyUrl", "/signup/verify-otp");
        model.addAttribute("resendUrl", "/signup/verify-otp/resend");
        return "otp/verify-otp";
    }

    @PostMapping("/verify-otp")
    public String verifyOtp(@RequestParam("code") String code, HttpSession session) {
        return registrationService.verifyOtpAndFinalize(code, session);
    }

    @PostMapping("/verify-otp/resend")
    public String resendOtp(HttpSession session) {
        return registrationService.resendOtp(session);
    }
}

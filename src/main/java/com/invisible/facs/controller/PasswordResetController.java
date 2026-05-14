package com.invisible.facs.controller;

import com.invisible.facs.service.UserService;
import com.invisible.facs.util.BanglaDigits;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class PasswordResetController {

    @Autowired
    private UserService userService;

    @GetMapping("/forgot-password")
    public String form() {
        return "user/forgot-password";
    }

    @PostMapping("/forgot-password")
    public String submit(@RequestParam("mobile") String rawMobile, HttpSession session) {
        return userService.requestPasswordReset(rawMobile, session);
    }

    @GetMapping("/verify-otp")
    public String otpForm(HttpSession session, Model model) {
        String mobile = userService.getResetMobile(session);
        if (mobile == null) return "redirect:/forgot-password";
        model.addAttribute("maskedMobile", BanglaDigits.formatMobile(mobile));
        model.addAttribute("verifyUrl", "/verify-otp");
        model.addAttribute("resendUrl", "/verify-otp/resend");
        return "otp/verify-otp";
    }

    @PostMapping("/verify-otp")
    public String verify(@RequestParam("code") String code, HttpSession session) {
        return userService.verifyResetOtp(code, session);
    }

    @PostMapping("/verify-otp/resend")
    public String resend(HttpSession session) {
        return userService.resendResetOtp(session);
    }

    @GetMapping("/reset-password")
    public String resetForm(HttpSession session) {
        if (!userService.isResetVerified(session)) return "redirect:/forgot-password";
        return "user/reset-password";
    }

    @PostMapping("/reset-password")
    public String resetSubmit(@RequestParam("password") String password,
                              @RequestParam("passwordConfirm") String passwordConfirm,
                              HttpSession session) {
        return userService.submitNewPassword(password, passwordConfirm, session);
    }
}

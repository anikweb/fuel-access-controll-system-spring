package com.invisible.facs.controller;

import com.invisible.facs.util.RoleRedirects;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomeController {

    @GetMapping("/")
    public String landing(Authentication auth,
                          @RequestParam(value = "error", required = false) String error,
                          @RequestParam(value = "registered", required = false) String registered,
                          @RequestParam(value = "passwordReset", required = false) String passwordReset,
                          Model model) {
        if (auth != null && auth.isAuthenticated()
                && !(auth instanceof AnonymousAuthenticationToken)) {
            return "redirect:" + RoleRedirects.pathFor(auth);
        }
        if (error != null) {
            model.addAttribute("loginError", "মোবাইল নম্বর বা পাসওয়ার্ড সঠিক নয়।");
        }
        if (registered != null) {
            model.addAttribute("loginNotice", "অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে। সাইন ইন করুন।");
        }
        if (passwordReset != null) {
            model.addAttribute("loginNotice", "পাসওয়ার্ড সফলভাবে আপডেট হয়েছে। নতুন পাসওয়ার্ড দিয়ে সাইন ইন করুন।");
        }
        return "user/signin";
    }
}

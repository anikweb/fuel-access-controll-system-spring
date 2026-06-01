package com.invisible.facs.controller;

import com.invisible.facs.service.UserService;
import com.invisible.facs.util.RoleRedirects;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.security.Principal;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

@Controller
@RequiredArgsConstructor
public class ChangePasswordController {

    private static final String S_CHANGED_AT = "passwordChangedAt";
    private static final String S_CHANGED_IP = "passwordChangedIp";

    private static final DateTimeFormatter TIME_FMT =
            DateTimeFormatter.ofPattern("HH:mm:ss").withZone(ZoneOffset.UTC);

    private final UserService userService;

    @GetMapping("/change-password")
    public String form(Principal principal) {
        if (principal == null) return "redirect:/";
        return "user/change-password";
    }

    @PostMapping("/change-password")
    public String submit(@RequestParam("currentPassword") String currentPassword,
                         @RequestParam("newPassword") String newPassword,
                         @RequestParam("confirmPassword") String confirmPassword,
                         Principal principal,
                         HttpServletRequest request,
                         HttpSession session) {
        if (principal == null) return "redirect:/";

        UserService.ChangePasswordResult result =
                userService.changePassword(principal.getName(), currentPassword, newPassword, confirmPassword);

        switch (result) {
            case INVALID_CURRENT:  return "redirect:/change-password?error=current";
            case WEAK:             return "redirect:/change-password?error=weak";
            case MISMATCH:         return "redirect:/change-password?error=mismatch";
            case SAME_AS_CURRENT:  return "redirect:/change-password?error=same";
            case USER_MISSING:     return "redirect:/";
            case SUCCESS:
            default:
                session.setAttribute(S_CHANGED_AT, TIME_FMT.format(Instant.now()) + " UTC");
                session.setAttribute(S_CHANGED_IP, clientIp(request));
                return "redirect:/change-password/success";
        }
    }

    @GetMapping("/change-password/success")
    public String success(Authentication authentication, HttpSession session, Model model) {
        if (authentication == null) return "redirect:/";
        Object changedAt = session.getAttribute(S_CHANGED_AT);
        Object changedIp = session.getAttribute(S_CHANGED_IP);
        if (changedAt == null) return "redirect:/change-password";

        model.addAttribute("changedAt", changedAt);
        model.addAttribute("changedIp", changedIp);
        model.addAttribute("dashboardUrl", RoleRedirects.pathFor(authentication));
        session.removeAttribute(S_CHANGED_AT);
        session.removeAttribute(S_CHANGED_IP);
        return "user/password-changed";
    }

    private String clientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            int comma = forwarded.indexOf(',');
            return (comma > 0 ? forwarded.substring(0, comma) : forwarded).trim();
        }
        return request.getRemoteAddr();
    }
}

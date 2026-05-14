package com.invisible.facs.controller;

import com.invisible.facs.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class DashboardController {

    private final UserService userService;

    @GetMapping("/dashboard")
    public String dashboard(Principal principal, Model model) {
        return userService.prepareDashboard(principal, model);
    }
}

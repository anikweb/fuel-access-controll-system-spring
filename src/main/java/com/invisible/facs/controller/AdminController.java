package com.invisible.facs.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.security.Principal;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @GetMapping({"", "/", "/dashboard"})
    public String dashboard(Principal principal, Model model) {
        model.addAttribute("displayName", principal == null ? "" : principal.getName());
        return "admin/dashboard";
    }
}

package com.invisible.facs.util;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

public final class RoleRedirects {

    public static final String ADMIN_DASHBOARD = "/admin/dashboard";
    public static final String OPERATOR_DASHBOARD = "/operator/dashboard";
    public static final String VEHICLE_OWNER_DASHBOARD = "/dashboard";

    private RoleRedirects() {}

    public static String pathFor(Authentication authentication) {
        if (authentication == null) {
            return VEHICLE_OWNER_DASHBOARD;
        }
        for (GrantedAuthority a : authentication.getAuthorities()) {
            String role = a.getAuthority();
            if ("ROLE_ADMIN".equals(role)) return ADMIN_DASHBOARD;
            if ("ROLE_OPERATOR".equals(role)) return OPERATOR_DASHBOARD;
        }
        return VEHICLE_OWNER_DASHBOARD;
    }
}

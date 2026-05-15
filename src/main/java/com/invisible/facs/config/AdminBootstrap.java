package com.invisible.facs.config;

import com.invisible.facs.model.Role;
import com.invisible.facs.model.User;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.util.MobileNumbers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class AdminBootstrap implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.admin.mobile:}")
    private String adminMobile;

    @Value("${app.admin.password:}")
    private String adminPassword;

    @Value("${app.admin.name:Administrator}")
    private String adminName;

    @Override
    public void run(String... args) {
        if (userRepository.existsByRole(Role.ADMIN)) {
            return;
        }
        if (adminMobile == null || adminMobile.isBlank()
                || adminPassword == null || adminPassword.isBlank()) {
            log.warn("No admin exists and app.admin.mobile / app.admin.password are not set — skipping admin bootstrap.");
            return;
        }
        String mobile = MobileNumbers.normalize(adminMobile);
        if (userRepository.findByMobile(mobile).isPresent()) {
            log.warn("Admin bootstrap skipped — mobile {} already exists with a non-admin role.", mobile);
            return;
        }
        User admin = User.builder()
                .mobile(mobile)
                .passwordHash(passwordEncoder.encode(adminPassword))
                .name(adminName)
                .role(Role.ADMIN)
                .build();
        userRepository.save(admin);
        log.info("Seeded ADMIN user mobile={}", mobile);
    }
}

package com.invisible.facs.config;

import com.invisible.facs.security.RoleBasedAuthSuccessHandler;
import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final RoleBasedAuthSuccessHandler roleBasedAuthSuccessHandler;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception
    {
        http.authorizeHttpRequests(auth->auth
                        .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.INCLUDE).permitAll()
                        .requestMatchers("/", "/forgot-password", "/verify-otp", "/verify-otp/**", "/reset-password", "/reset-password/**", "/signup", "/signup/**", "/css/**", "/js/**", "/img/**", "/uploads/**", "/error", "/favicon.ico").permitAll()
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers("/operator/**").hasRole("OPERATOR")
                        .requestMatchers("/dashboard", "/dashboard/**").hasRole("VEHICLE_OWNER")
                        .anyRequest().authenticated())
                .csrf(Customizer.withDefaults())
                .formLogin(form->form
                        .loginPage("/")
                        .loginProcessingUrl("/signin")
                        .usernameParameter("mobile")
                        .passwordParameter("password")
                        .successHandler(roleBasedAuthSuccessHandler)
                        .failureUrl("/?error")
                        .permitAll())
                .logout(logout->logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/")
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID")
                        .permitAll());
        return http.build();
    }
}

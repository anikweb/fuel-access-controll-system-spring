package com.invisible.facs.service;

import com.invisible.facs.model.User;
import com.invisible.facs.repository.UserRepository;
import com.invisible.facs.util.MobileNumbers;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String mobile) throws UsernameNotFoundException {
        String normalized = MobileNumbers.normalize(mobile);
        Optional<User> userOpt = userRepository.findByMobile(normalized);
        if (userOpt.isEmpty()) {
            throw new UsernameNotFoundException("No account for mobile: " + mobile);
        }
        User user = userOpt.get();

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getMobile())
                .password(user.getPasswordHash())
                .authorities(List.of(new SimpleGrantedAuthority("ROLE_USER")))
                .build();
    }
}

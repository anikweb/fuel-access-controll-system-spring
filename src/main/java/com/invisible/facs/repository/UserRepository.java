package com.invisible.facs.repository;

import com.invisible.facs.model.Role;
import com.invisible.facs.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByMobile(String mobile);

    boolean existsByRole(Role role);

    long countByRole(Role role);

    Page<User> findByRoleIn(Collection<Role> roles, Pageable pageable);
}

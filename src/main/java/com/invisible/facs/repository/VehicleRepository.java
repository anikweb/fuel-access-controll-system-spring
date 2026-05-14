package com.invisible.facs.repository;

import com.invisible.facs.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    List<Vehicle> findByUserIdOrderByCreatedAtDesc(Long userId);
}

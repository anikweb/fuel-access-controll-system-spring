package com.invisible.facs.repository;

import com.invisible.facs.model.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    List<Vehicle> findByUserIdOrderByCreatedAtDesc(Long userId);

    Optional<Vehicle> findFirstByPlateNumberIgnoreCase(String plateNumber);
}

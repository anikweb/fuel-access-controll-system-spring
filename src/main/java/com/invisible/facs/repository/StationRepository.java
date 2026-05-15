package com.invisible.facs.repository;

import com.invisible.facs.model.Station;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StationRepository extends JpaRepository<Station, Long> {
    boolean existsByCode(String code);
}

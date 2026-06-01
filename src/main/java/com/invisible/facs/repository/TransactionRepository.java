package com.invisible.facs.repository;

import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    @Query("""
            SELECT t FROM Transaction t
            LEFT JOIN t.vehicle v
            LEFT JOIN t.station s
            WHERE (:q IS NULL
                   OR LOWER(t.code) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(v.plateNumber) LIKE LOWER(CONCAT('%', :q, '%')))
              AND (:stationId IS NULL OR s.id = :stationId)
              AND (:status IS NULL OR t.status = :status)
              AND (:fromAt IS NULL OR t.createdAt >= :fromAt)
              AND (:toAt IS NULL OR t.createdAt < :toAt)
            """)
    Page<Transaction> findWithFilters(
            @Param("q") String q,
            @Param("stationId") Long stationId,
            @Param("status") TransactionStatus status,
            @Param("fromAt") Instant fromAt,
            @Param("toAt") Instant toAt,
            Pageable pageable);

    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.createdAt >= :fromAt AND t.createdAt < :toAt")
    long countInRange(@Param("fromAt") Instant fromAt, @Param("toAt") Instant toAt);
}

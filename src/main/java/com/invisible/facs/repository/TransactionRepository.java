package com.invisible.facs.repository;

import com.invisible.facs.model.Transaction;
import com.invisible.facs.model.TransactionStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {

    @Query("""
            SELECT t FROM Transaction t
            LEFT JOIN t.vehicle v
            LEFT JOIN t.station s
            WHERE (:q IS NULL
                   OR LOWER(t.code) LIKE LOWER(CONCAT('%', :q, '%'))
                   OR LOWER(v.plateNumber) LIKE LOWER(CONCAT('%', :q, '%')))
              AND (:stationId IS NULL OR s.id = :stationId)
              AND (:operatorId IS NULL OR t.operator.id = :operatorId)
              AND (:vehicleUserId IS NULL OR v.user.id = :vehicleUserId)
              AND (:status IS NULL OR t.status = :status)
              AND (:fuelType IS NULL OR t.fuelType = :fuelType)
              AND (:fromAt IS NULL OR t.createdAt >= :fromAt)
              AND (:toAt IS NULL OR t.createdAt < :toAt)
            """)
    Page<Transaction> findWithFilters(
            @Param("q") String q,
            @Param("stationId") Long stationId,
            @Param("operatorId") Long operatorId,
            @Param("vehicleUserId") Long vehicleUserId,
            @Param("status") TransactionStatus status,
            @Param("fuelType") String fuelType,
            @Param("fromAt") Instant fromAt,
            @Param("toAt") Instant toAt,
            Pageable pageable);

    List<Transaction> findTop10ByVehicleUserIdOrderByCreatedAtDesc(Long userId);

    @Query("""
            SELECT t.vehicle.id, COALESCE(SUM(t.fuelLiters), 0)
            FROM Transaction t
            WHERE t.status = :status
              AND t.vehicle.user.id = :userId
              AND t.createdAt >= :fromAt
              AND t.createdAt < :toAt
            GROUP BY t.vehicle.id
            """)
    List<Object[]> sumLitersByVehicleForUserInRange(@Param("userId") Long userId,
                                                    @Param("status") TransactionStatus status,
                                                    @Param("fromAt") Instant fromAt,
                                                    @Param("toAt") Instant toAt);

    @Query("SELECT COUNT(t) FROM Transaction t WHERE t.createdAt >= :fromAt AND t.createdAt < :toAt")
    long countInRange(@Param("fromAt") Instant fromAt, @Param("toAt") Instant toAt);

    long countByOperatorIdAndStatus(Long operatorId, TransactionStatus status);

    @Query("SELECT COALESCE(SUM(t.fuelLiters), 0) FROM Transaction t " +
           "WHERE t.operator.id = :operatorId AND t.status = :status")
    BigDecimal sumFuelLitersByOperatorIdAndStatus(@Param("operatorId") Long operatorId,
                                                   @Param("status") TransactionStatus status);

    List<Transaction> findTop10ByOperatorIdOrderByCreatedAtDesc(Long operatorId);

    Optional<Transaction> findFirstByVehicleIdOrderByCreatedAtDesc(Long vehicleId);

    boolean existsByCode(String code);
}

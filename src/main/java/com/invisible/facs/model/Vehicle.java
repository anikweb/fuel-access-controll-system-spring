package com.invisible.facs.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;
import java.time.Instant;

@Entity
@Table(name = "vehicles", indexes = {
        @Index(name = "ix_vehicles_user_id", columnList = "user_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Vehicle implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @NotBlank
    @Column(name = "brand_code", length = 64)
    private String brand;

    @Size(max = 120)
    @Column(name = "model", length = 120)
    private String model;

    @NotBlank
    @Column(name = "vehicle_type_code", length = 64)
    private String vehicleType;

    @NotBlank
    @Size(max = 64)
    @Column(name = "chassis_number", length = 64)
    private String chassisNumber;

    @Size(max = 64)
    @Column(name = "engine_number", length = 64)
    private String engineNumber;

    @Size(max = 64)
    @Column(name = "color", length = 64)
    private String color;

    @Size(max = 16)
    @Column(name = "manufacture_year", length = 16)
    private String manufactureYear;

    @NotBlank
    @Size(max = 64)
    @Column(name = "plate_number", length = 64)
    private String plateNumber;

    @Column(name = "plate_image_path", length = 255)
    private String plateImageRef;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() {
        if (createdAt == null) createdAt = Instant.now();
    }
}

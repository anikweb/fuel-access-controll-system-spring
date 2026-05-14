package com.invisible.facs.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "name", length = 160)
    private String name;

    @Column(name = "license_number", length = 64)
    private String licenseNumber;

    @Column(name = "nid_number", length = 64)
    private String nidNumber;

    @Column(name = "address", columnDefinition = "TEXT")
    private String address;

    @Column(name = "district", length = 64)
    private String district;

    @Column(name = "sub_district", length = 64)
    private String subDistrict;

    @Column(name = "photo_path", length = 255)
    private String photoPath;

    @Column(name = "license_front_path", length = 255)
    private String licenseFrontPath;

    @Column(name = "license_back_path", length = 255)
    private String licenseBackPath;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @PrePersist
    void onCreate() {
        Instant now = Instant.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = Instant.now();
    }
}

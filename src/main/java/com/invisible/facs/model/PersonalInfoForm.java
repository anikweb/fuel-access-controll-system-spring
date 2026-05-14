package com.invisible.facs.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;

@Data
public class PersonalInfoForm implements Serializable {

    @NotBlank
    @Size(max = 160)
    private String name;

    @NotBlank
    @Size(max = 64)
    private String licenseNumber;

    @NotBlank
    private String district;

    @NotBlank
    private String subDistrict;

    @Size(max = 1000)
    private String address;

    @NotBlank
    @Size(max = 64)
    private String nidNumber;

    /** Public URL path (e.g. /uploads/users/photos/<uuid>.jpg). Set by FileStorageService. */
    private String photoPath;
    private String licenseFrontPath;
    private String licenseBackPath;
}

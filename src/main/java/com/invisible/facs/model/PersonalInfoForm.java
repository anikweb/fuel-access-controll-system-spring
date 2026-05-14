package com.invisible.facs.model;

import jakarta.persistence.Column;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;

@Data
public class PersonalInfoForm implements Serializable {

    @NotBlank
    @Size(max = 100)
    private String name;

    @NotBlank
    @Size(max = 100)
    private String licenseNumber;

    @NotBlank
    private String district;

    @NotBlank
    private String subDistrict;

    @Size(max = 500)
    private String address;

    @NotBlank
    @Size(max = 64)
    private String nidNumber;

    @Size(max = 500)
    private String photoPath;

    @Size(max = 500)
    private String licenseFrontPath;
    
    @Size(max = 500)
    private String licenseBackPath;
}

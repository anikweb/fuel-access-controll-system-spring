package com.invisible.facs.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class PanelUserForm {

    @NotBlank(message = "নাম আবশ্যক")
    @Size(max = 120, message = "নাম ১২০ অক্ষরের মধ্যে রাখুন")
    private String name;

    @NotBlank(message = "মোবাইল নম্বর আবশ্যক")
    private String mobile;

    @NotBlank(message = "ভূমিকা নির্বাচন করুন")
    private String role;

    private Long stationId;

    private String password;
    private String passwordConfirm;

    private MultipartFile photo;
}

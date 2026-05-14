package com.invisible.facs.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.io.Serializable;

@Data
public class SecurityForm implements Serializable {

    @NotBlank
    @Pattern(regexp = "^(\\+?880|0)?1[3-9]\\d{8}$", message = "অবৈধ মোবাইল নম্বর")
    private String mobile;

    @NotBlank
    @Size(min = 8, max = 100, message = "পাসওয়ার্ড কমপক্ষে ৮ অক্ষর হতে হবে")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$",
            message = "পাসওয়ার্ডে কমপক্ষে একটি বড় হাতের অক্ষর, একটি ছোট হাতের অক্ষর ও একটি সংখ্যা থাকতে হবে")
    private String password;

    @NotBlank
    private String passwordConfirm;
}

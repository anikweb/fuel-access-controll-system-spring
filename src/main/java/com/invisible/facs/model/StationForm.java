package com.invisible.facs.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class StationForm {

    @NotBlank(message = "স্টেশনের নাম আবশ্যক")
    @Size(max = 120, message = "নাম ১২০ অক্ষরের মধ্যে রাখুন")
    private String name;

    @NotBlank(message = "ঠিকানা আবশ্যক")
    @Size(max = 160, message = "ঠিকানা ১৬০ অক্ষরের মধ্যে রাখুন")
    private String location;
}

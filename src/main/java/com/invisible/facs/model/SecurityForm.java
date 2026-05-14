package com.invisible.facs.model;

import com.invisible.facs.util.PasswordRules;
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
    @Size(min = PasswordRules.MIN_LENGTH, max = PasswordRules.MAX_LENGTH,
            message = PasswordRules.LENGTH_MESSAGE)
    @Pattern(regexp = PasswordRules.PATTERN_REGEX, message = PasswordRules.PATTERN_MESSAGE)
    private String password;

    @NotBlank
    private String passwordConfirm;
}

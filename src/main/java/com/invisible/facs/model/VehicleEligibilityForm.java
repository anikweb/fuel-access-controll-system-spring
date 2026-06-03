package com.invisible.facs.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
public class VehicleEligibilityForm {

    private BigDecimal monthlyQuotaLiters;
    private Integer cooldownHours;
}

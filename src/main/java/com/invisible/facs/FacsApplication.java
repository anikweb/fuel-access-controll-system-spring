package com.invisible.facs;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class FacsApplication {

	public static void main(String[] args) {
		SpringApplication.run(FacsApplication.class, args);
	}

}

package com.example.jersey;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication
@EntityScan(basePackages = "com.example.common.model")
public class JerseyApplication {

    public static void main(String[] args) {
        SpringApplication.run(JerseyApplication.class, args);
    }
}

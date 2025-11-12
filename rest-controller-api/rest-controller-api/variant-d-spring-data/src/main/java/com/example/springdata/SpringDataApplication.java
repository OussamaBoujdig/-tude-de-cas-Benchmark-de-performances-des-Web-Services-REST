package com.example.springdata;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication
@EntityScan(basePackages = "com.example.common.model")
public class SpringDataApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringDataApplication.class, args);
    }
}

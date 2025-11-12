package com.example.spring;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = {
        "com.example.spring",
        "com.example.common"      // ✅ pour scanner les modèles entités
})
@EntityScan(basePackages = {
        "com.example.common.model"  // ✅ pour que Category soit trouvé
})
@EnableJpaRepositories(basePackages = {
        "com.example.spring.repository" // ✅ contient CategoryRepository
})
public class RestControllerApplication {

    public static void main(String[] args) {
        SpringApplication.run(RestControllerApplication.class, args);
    }
}

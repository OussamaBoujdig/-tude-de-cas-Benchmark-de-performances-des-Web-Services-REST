package com.example.jersey.config;

import com.example.jersey.resource.CategoryResource;
import com.example.jersey.resource.ItemResource;
import jakarta.ws.rs.ApplicationPath;
import org.glassfish.jersey.server.ResourceConfig;
import org.springframework.context.annotation.Configuration;

@Configuration
@ApplicationPath("/")
public class JerseyConfig extends ResourceConfig {

    public JerseyConfig() {
        // Register REST resources
        register(CategoryResource.class);
        register(ItemResource.class);
        
        // Register exception mappers
        register(com.example.jersey.exception.GlobalExceptionMapper.class);
    }
}

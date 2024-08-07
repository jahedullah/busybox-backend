package com.jahedul.busybox_backend.configs;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class SecurityConfiguration {

  @Bean
  public WebMvcConfigurer corsConfigurer() {
    return new WebMvcConfigurer() {
      public void addCorsMappings(final CorsRegistry registry) {
        registry.addMapping("/**")
            .allowedHeaders("*")
            .allowedMethods("*")
            .allowedOrigins("http://192.168.105.4:31000/",
                "http://busybox-backend-service.default.svc.cluster.local:8080/", "http://34.69.68.24:31000/",
                "http://localhost:4200/", "http://localhost:8001/", "http://localhost:8001");
      }
    };
  }

  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration corsConfiguration = new CorsConfiguration();
    corsConfiguration.addAllowedMethod("*");
    corsConfiguration.addAllowedOrigin("http://busybox-backend-service.default.svc.cluster.local:8080/");
    corsConfiguration.addAllowedOrigin("http://192.168.105.4:31000/");
    corsConfiguration.addAllowedOrigin("http://34.69.68.24:31000/");
    corsConfiguration.addAllowedOrigin("http://localhost:4200/");
    corsConfiguration.addAllowedOrigin("http://localhost:8001/");
    corsConfiguration.addAllowedOrigin("http://localhost:8001");
    corsConfiguration.addAllowedHeader("*");
    corsConfiguration.setAllowCredentials(true);

    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", corsConfiguration);

    return source;
  }
}

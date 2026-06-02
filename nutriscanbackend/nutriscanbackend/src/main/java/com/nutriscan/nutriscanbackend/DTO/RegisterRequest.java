package com.nutriscan.nutriscanbackend.DTO;

import lombok.Data;

@Data
public class RegisterRequest {

    private String firstName;
    private String lastName;
    private Integer age;
    private String gender;
    private Double weight;
    private Double height;
    private String target;
    private String email;
    private String password;
}
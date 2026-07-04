package com.nutriscan.nutriscanbackend.DTO;

import lombok.Data;
import java.util.List;

@Data
public class RegisterRequest {

    private String firstName;
    private String lastName;
    private Integer age;
    private String gender;
    private Double weight;
    private Double height;
    private String target;
    private Double targetWeight;
    private Integer targetDays;
    private String email;
    private String password;
    private List<String> allergens;
}
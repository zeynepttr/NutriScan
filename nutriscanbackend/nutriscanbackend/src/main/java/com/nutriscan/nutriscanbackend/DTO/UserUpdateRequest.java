package com.nutriscan.nutriscanbackend.DTO;

import lombok.Data;

@Data
public class UserUpdateRequest {
    private String firstName;
    private String lastName;
    private Integer age;
    private String gender;
    private Double weight;
    private Double height;
    private String target;
    private Integer dailyCalorieTarget;
}

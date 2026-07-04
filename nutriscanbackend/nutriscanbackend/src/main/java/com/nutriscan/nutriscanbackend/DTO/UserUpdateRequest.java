package com.nutriscan.nutriscanbackend.DTO;

import lombok.Data;
import java.util.List;

@Data
public class UserUpdateRequest {
    private String firstName;
    private String lastName;
    private Integer age;
    private String gender;
    private Double weight;
    private Double height;
    private String target;
    private Double targetWeight;
    private Integer targetDays;
    private Integer dailyCalorieTarget;
    private List<String> allergens;
}

package com.nutriscan.nutriscanbackend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserResponse {
    private Long id;
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
    private String email;
    private List<String> allergens;
}

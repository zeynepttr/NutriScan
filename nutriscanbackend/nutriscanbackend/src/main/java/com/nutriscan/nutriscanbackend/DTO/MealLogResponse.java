package com.nutriscan.nutriscanbackend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealLogResponse {
    private Long id;
    private LocalDate date;
    private String foodName;
    private float calories;
    private float fat;
    private float protein;
    private float carbohydrate;
    private float confidence;
    private boolean containsAllergen;
    private String allergenWarning;
}

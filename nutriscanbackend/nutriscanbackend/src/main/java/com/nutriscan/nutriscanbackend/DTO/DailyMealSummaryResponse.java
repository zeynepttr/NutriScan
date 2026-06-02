package com.nutriscan.nutriscanbackend.DTO;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DailyMealSummaryResponse {
    private LocalDate date;
    private List<MealLogResponse> meals;
    private float totalCalories;
    private float totalFat;
    private float totalProtein;
    private float totalCarbohydrate;
}

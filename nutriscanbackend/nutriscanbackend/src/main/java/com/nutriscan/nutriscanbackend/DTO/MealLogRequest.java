package com.nutriscan.nutriscanbackend.DTO;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.time.LocalDate;

@Data
public class MealLogRequest {

    private LocalDate date;

    @NotBlank(message = "Food name is required")
    private String foodName;

    @Min(value = 0, message = "Calories cannot be negative")
    private float calories;

    @Min(value = 0, message = "Fat cannot be negative")
    private float fat;

    @Min(value = 0, message = "Protein cannot be negative")
    private float protein;

    @Min(value = 0, message = "Carbohydrate cannot be negative")
    private float carbohydrate;

    private float confidence;
}

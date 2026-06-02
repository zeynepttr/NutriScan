package com.nutriscan.nutriscanbackend.DTO;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class FoodRequest {

    @NotBlank(message = "Food name is required")
    private String name;

    @Min(value = 0, message = "Calories cannot be negative")
    private float calories;

    @Min(value = 0, message = "Fat cannot be negative")
    private float fat;

    @Min(value = 0, message = "Protein cannot be negative")
    private float protein;

    @Min(value = 0, message = "Carbohydrate cannot be negative")
    private float carbohydrate;
}

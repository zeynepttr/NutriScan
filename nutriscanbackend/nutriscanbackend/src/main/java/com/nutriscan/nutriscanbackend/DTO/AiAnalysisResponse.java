package com.nutriscan.nutriscanbackend.DTO;

import lombok.Data;

@Data
public class AiAnalysisResponse {
    private String food;
    private float confidence;
    private Nutrition nutrition;

    @Data
    public static class Nutrition {
        private float calories;
        private float fat_g;
        private float carb_g;
        private float protein_g;
    }
}

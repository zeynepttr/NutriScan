package com.nutriscan.nutriscanbackend.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class LlmCalorieService {

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    public int calculateCalories(int age, String gender, double weight, double height, String target, Double targetWeight, Integer targetDays) {
        int fallbackCalorie = calculateMifflinStJeor(age, gender, weight, height, target, targetWeight, targetDays);

        if (geminiApiKey == null || geminiApiKey.trim().isEmpty()) {
            log.info("Gemini API key is not configured. Using Mifflin-St Jeor formula: {}", fallbackCalorie);
            return fallbackCalorie;
        }

        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + geminiApiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            String prompt;
            if (targetWeight != null && targetDays != null && targetDays > 0) {
                prompt = String.format(
                        "You are a professional nutritionist. Calculate the daily calorie target for a person with the following attributes:\n" +
                        "- Age: %d\n" +
                        "- Gender: %s\n" +
                        "- Current Weight: %.1f kg\n" +
                        "- Height: %.1f cm\n" +
                        "- Goal: %s\n" +
                        "- Target Weight: %.1f kg\n" +
                        "- Target Duration: %d days\n\n" +
                        "Please calculate the necessary daily calorie intake to safely and healthily achieve this goal within the given timeframe. " +
                        "Return ONLY the calculated daily calorie target as a single integer number. Do not write any other words, code, markdown, punctuation or explanations. Example: 2150",
                        age, gender, weight, height, target, targetWeight, targetDays
                );
            } else {
                prompt = String.format(
                        "You are a professional nutritionist. Calculate the daily calorie target for a person with the following attributes: " +
                        "Age: %d, Gender: %s, Weight: %.1f kg, Height: %.1f cm, Goal: %s. " +
                        "Return ONLY the calculated integer calorie number. Do not write any other words, code, markdown, punctuation or explanations. Example: 2150",
                        age, gender, weight, height, target
                );
            }

            Map<String, Object> textPart = new HashMap<>();
            textPart.put("text", prompt);

            Map<String, Object> partsMap = new HashMap<>();
            partsMap.put("parts", List.of(textPart));

            Map<String, Object> payload = new HashMap<>();
            payload.put("contents", List.of(partsMap));

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);
            Map<String, Object> response = restTemplate.postForObject(url, entity, Map.class);

            if (response != null && response.containsKey("candidates")) {
                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
                if (!candidates.isEmpty()) {
                    Map<String, Object> firstCandidate = candidates.get(0);
                    Map<String, Object> content = (Map<String, Object>) firstCandidate.get("content");
                    List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
                    if (!parts.isEmpty()) {
                        String text = (String) parts.get(0).get("text");
                        String cleanedText = text.replaceAll("[^0-9]", "").trim();
                        if (!cleanedText.isEmpty()) {
                            int cal = Integer.parseInt(cleanedText);
                            if (cal > 500 && cal < 8000) {
                                log.info("Successfully calculated calories via Gemini: {}", cal);
                                return cal;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            log.error("Failed to calculate calories via Gemini API: {}. Using fallback.", e.getMessage());
        }

        return fallbackCalorie;
    }

    public int calculateCalories(int age, String gender, double weight, double height, String target) {
        return calculateCalories(age, gender, weight, height, target, null, null);
    }

    private int calculateMifflinStJeor(int age, String gender, double weight, double height, String target, Double targetWeight, Integer targetDays) {
        double bmr;
        if ("FEMALE".equalsIgnoreCase(gender) || "KADIN".equalsIgnoreCase(gender)) {
            bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        }

        double tdee = bmr * 1.375; // Light activity factor

        if (targetWeight != null && targetDays != null && targetDays > 0) {
            double deltaWeight = weight - targetWeight; // Positive for weight loss, negative for weight gain
            // 1 kg body weight is approx 7700 kcal
            double dailyCalAdjustment = (deltaWeight * 7700.0) / targetDays;
            int cal = (int) Math.round(tdee - dailyCalAdjustment);

            // Safe limits logic:
            int minCal = ("FEMALE".equalsIgnoreCase(gender) || "KADIN".equalsIgnoreCase(gender)) ? 1200 : 1500;
            if (cal < minCal) {
                log.warn("Calculated calories ({}) are below safe threshold. Capping at {}", cal, minCal);
                return minCal;
            }
            return cal;
        }

        if ("LOSE_WEIGHT".equalsIgnoreCase(target) || "VERME".equalsIgnoreCase(target) || "KILO_VERME".equalsIgnoreCase(target)) {
            return (int) Math.round(tdee - 500);
        } else if ("GAIN_WEIGHT".equalsIgnoreCase(target) || "ALMA".equalsIgnoreCase(target) || "KILO_ALMA".equalsIgnoreCase(target)) {
            return (int) Math.round(tdee + 400);
        } else {
            return (int) Math.round(tdee);
        }
    }

    public static void validateWeightGoal(Double currentWeight, String target, Double targetWeight, Integer targetDays) {
        if (currentWeight == null || target == null) {
            return;
        }

        String cleanTarget = target.trim().toUpperCase();
        if ("LOSE_WEIGHT".equals(cleanTarget) || "VERME".equals(cleanTarget) || "KILO_VERME".equals(cleanTarget)) {
            if (targetWeight == null) {
                throw new IllegalArgumentException("Kilo verme hedefi seçildiğinde hedef kilo girilmesi zorunludur.");
            }
            if (targetWeight >= currentWeight) {
                throw new IllegalArgumentException("Kilo verme hedefi için hedef kilo mevcut kilodan düşük olmalıdır.");
            }
            if (targetDays == null || targetDays <= 0) {
                throw new IllegalArgumentException("Kilo değişimi için hedef gün sayısı belirtilmelidir.");
            }
            // En fazla haftalık 1.5 kg kayıp
            double minDays = Math.ceil(((currentWeight - targetWeight) / 1.5) * 7.0);
            if (targetDays < minDays) {
                throw new IllegalArgumentException("Haftalık en fazla 1.5 kg verilmesi sağlıklı kabul edilir. Belirttiğiniz hedefe ulaşmak için hedef süreniz en az " + (int)minDays + " gün olmalıdır.");
            }
        } else if ("GAIN_WEIGHT".equals(cleanTarget) || "ALMA".equals(cleanTarget) || "KILO_ALMA".equals(cleanTarget)) {
            if (targetWeight == null) {
                throw new IllegalArgumentException("Kilo alma hedefi seçildiğinde hedef kilo girilmesi zorunludur.");
            }
            if (targetWeight <= currentWeight) {
                throw new IllegalArgumentException("Kilo alma hedefi için hedef kilo mevcut kilodan yüksek olmalıdır.");
            }
            if (targetDays == null || targetDays <= 0) {
                throw new IllegalArgumentException("Kilo değişimi için hedef gün sayısı belirtilmelidir.");
            }
            // En fazla haftalık 1.5 kg alım
            double minDays = Math.ceil(((targetWeight - currentWeight) / 1.5) * 7.0);
            if (targetDays < minDays) {
                throw new IllegalArgumentException("Haftalık en fazla 1.5 kg alınması sağlıklı kabul edilir. Belirttiğiniz hedefe ulaşmak için hedef süreniz en az " + (int)minDays + " gün olmalıdır.");
            }
        }
    }
}

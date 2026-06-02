package com.nutriscan.nutriscanbackend.service;

import com.nutriscan.nutriscanbackend.DTO.AiAnalysisResponse;
import com.nutriscan.nutriscanbackend.DTO.DailyMealSummaryResponse;
import com.nutriscan.nutriscanbackend.DTO.MealLogRequest;
import com.nutriscan.nutriscanbackend.DTO.MealLogResponse;
import com.nutriscan.nutriscanbackend.entity.MealLog;
import com.nutriscan.nutriscanbackend.entity.User;
import com.nutriscan.nutriscanbackend.repository.MealLogRepository;
import com.nutriscan.nutriscanbackend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MealLogService {

    private final MealLogRepository mealLogRepository;
    private final UserRepository userRepository;

    @Value("${ai.api.url:http://localhost:5000}")
    private String aiApiUrl;

    @Transactional
    public MealLogResponse logMealFromImage(MultipartFile image, LocalDate date) throws IOException {
        User user = getAuthenticatedUser();
        LocalDate logDate = date != null ? date : LocalDate.now();

        // 1. Prepare request for Flask AI API
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        ByteArrayResource fileResource = new ByteArrayResource(image.getBytes()) {
            @Override
            public String getFilename() {
                return image.getOriginalFilename() != null ? image.getOriginalFilename() : "image.jpg";
            }
        };
        body.add("image", fileResource);

        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

        // 2. Call Flask AI API
        String url = aiApiUrl + "/analyze";
        AiAnalysisResponse aiResponse;
        try {
            aiResponse = restTemplate.postForObject(url, requestEntity, AiAnalysisResponse.class);
        } catch (Exception e) {
            throw new IllegalStateException("AI API is currently unavailable: " + e.getMessage(), e);
        }

        if (aiResponse == null || aiResponse.getFood() == null) {
            throw new IllegalArgumentException("AI model failed to analyze the image or returned an empty response");
        }

        // 3. Map AI response and save to database
        MealLog mealLog = MealLog.builder()
                .user(user)
                .date(logDate)
                .foodName(aiResponse.getFood())
                .calories(aiResponse.getNutrition() != null ? aiResponse.getNutrition().getCalories() : 0.0f)
                .fat(aiResponse.getNutrition() != null ? aiResponse.getNutrition().getFat_g() : 0.0f)
                .protein(aiResponse.getNutrition() != null ? aiResponse.getNutrition().getProtein_g() : 0.0f)
                .carbohydrate(aiResponse.getNutrition() != null ? aiResponse.getNutrition().getCarb_g() : 0.0f)
                .confidence(aiResponse.getConfidence())
                .build();

        MealLog saved = mealLogRepository.save(mealLog);
        return mapToResponse(saved);
    }

    private User getAuthenticatedUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + email));
    }

    @Transactional
    public MealLogResponse logMeal(MealLogRequest request) {
        User user = getAuthenticatedUser();
        LocalDate logDate = request.getDate() != null ? request.getDate() : LocalDate.now();

        MealLog mealLog = MealLog.builder()
                .user(user)
                .date(logDate)
                .foodName(request.getFoodName())
                .calories(request.getCalories())
                .fat(request.getFat())
                .protein(request.getProtein())
                .carbohydrate(request.getCarbohydrate())
                .confidence(request.getConfidence())
                .build();

        MealLog saved = mealLogRepository.save(mealLog);
        return mapToResponse(saved);
    }

    @Transactional(readOnly = true)
    public DailyMealSummaryResponse getDailySummary(LocalDate date) {
        User user = getAuthenticatedUser();
        LocalDate targetDate = date != null ? date : LocalDate.now();

        List<MealLog> meals = mealLogRepository.findByUserAndDateOrderByCreatedAtDesc(user, targetDate);

        List<MealLogResponse> mealResponses = meals.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        float totalCal = 0;
        float totalFat = 0;
        float totalProt = 0;
        float totalCarb = 0;

        for (MealLog m : meals) {
            totalCal += m.getCalories();
            totalFat += m.getFat();
            totalProt += m.getProtein();
            totalCarb += m.getCarbohydrate();
        }

        return DailyMealSummaryResponse.builder()
                .date(targetDate)
                .meals(mealResponses)
                .totalCalories(Math.round(totalCal * 10.0f) / 10.0f)
                .totalFat(Math.round(totalFat * 10.0f) / 10.0f)
                .totalProtein(Math.round(totalProt * 10.0f) / 10.0f)
                .totalCarbohydrate(Math.round(totalCarb * 10.0f) / 10.0f)
                .build();
    }

    @Transactional
    public void deleteMealLog(Long id) {
        User user = getAuthenticatedUser();
        MealLog mealLog = mealLogRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Meal log not found with id: " + id));

        if (!mealLog.getUser().getId().equals(user.getId())) {
            throw new SecurityException("You do not have permission to delete this meal log");
        }

        mealLogRepository.delete(mealLog);
    }

    private MealLogResponse mapToResponse(MealLog log) {
        return MealLogResponse.builder()
                .id(log.getId())
                .date(log.getDate())
                .foodName(log.getFoodName())
                .calories(log.getCalories())
                .fat(log.getFat())
                .protein(log.getProtein())
                .carbohydrate(log.getCarbohydrate())
                .confidence(log.getConfidence())
                .build();
    }
}

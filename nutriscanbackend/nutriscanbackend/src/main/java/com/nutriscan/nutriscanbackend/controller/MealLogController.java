package com.nutriscan.nutriscanbackend.controller;

import com.nutriscan.nutriscanbackend.DTO.DailyMealSummaryResponse;
import com.nutriscan.nutriscanbackend.DTO.MealLogRequest;
import com.nutriscan.nutriscanbackend.DTO.MealLogResponse;
import com.nutriscan.nutriscanbackend.service.MealLogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDate;

@RestController
@RequestMapping("/api/meals")
@RequiredArgsConstructor
public class MealLogController {

    private final MealLogService mealLogService;

    @PostMapping
    public ResponseEntity<MealLogResponse> logMeal(@Valid @RequestBody MealLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(mealLogService.logMeal(request));
    }

    @PostMapping("/analyze-and-log")
    public ResponseEntity<MealLogResponse> logMealFromImage(
            @RequestParam("image") MultipartFile image,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) throws IOException {
        return ResponseEntity.status(HttpStatus.CREATED).body(mealLogService.logMealFromImage(image, date));
    }

    @GetMapping("/summary")
    public ResponseEntity<DailyMealSummaryResponse> getDailySummary(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(mealLogService.getDailySummary(date));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMealLog(@PathVariable Long id) {
        mealLogService.deleteMealLog(id);
        return ResponseEntity.noContent().build();
    }
}

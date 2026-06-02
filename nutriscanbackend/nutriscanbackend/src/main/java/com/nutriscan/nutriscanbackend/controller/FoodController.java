package com.nutriscan.nutriscanbackend.controller;

import com.nutriscan.nutriscanbackend.DTO.FoodRequest;
import com.nutriscan.nutriscanbackend.entity.Food;
import com.nutriscan.nutriscanbackend.service.FoodService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/foods")
@RequiredArgsConstructor
public class FoodController {

    private final FoodService foodService;

    @GetMapping
    public ResponseEntity<List<Food>> getAllFoods(@RequestParam(required = false) String search) {
        return ResponseEntity.ok(foodService.getAllFoods(search));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Food> getFoodById(@PathVariable Long id) {
        return ResponseEntity.ok(foodService.getFoodById(id));
    }

    @PostMapping
    public ResponseEntity<Food> createFood(@Valid @RequestBody FoodRequest request) {
        Food food = foodService.createFood(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(food);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Food> updateFood(@PathVariable Long id, @Valid @RequestBody FoodRequest request) {
        return ResponseEntity.ok(foodService.updateFood(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFood(@PathVariable Long id) {
        foodService.deleteFood(id);
        return ResponseEntity.noContent().build();
    }
}

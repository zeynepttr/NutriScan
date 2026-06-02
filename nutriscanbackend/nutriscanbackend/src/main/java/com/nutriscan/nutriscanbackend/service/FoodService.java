package com.nutriscan.nutriscanbackend.service;

import com.nutriscan.nutriscanbackend.DTO.FoodRequest;
import com.nutriscan.nutriscanbackend.entity.Food;
import com.nutriscan.nutriscanbackend.repository.FoodRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FoodService {

    private final FoodRepository foodRepository;

    public List<Food> getAllFoods(String search) {
        if (search != null && !search.trim().isEmpty()) {
            return foodRepository.findByNameContainingIgnoreCase(search.trim());
        }
        return foodRepository.findAll();
    }

    public Food getFoodById(Long id) {
        return foodRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + id));
    }

    public Food createFood(FoodRequest request) {
        Food food = new Food();
        food.setName(request.getName());
        food.setCalories(request.getCalories());
        food.setFat(request.getFat());
        food.setProtein(request.getProtein());
        food.setCarbohydrate(request.getCarbohydrate());
        return foodRepository.save(food);
    }

    public Food updateFood(Long id, FoodRequest request) {
        Food food = getFoodById(id);
        food.setName(request.getName());
        food.setCalories(request.getCalories());
        food.setFat(request.getFat());
        food.setProtein(request.getProtein());
        food.setCarbohydrate(request.getCarbohydrate());
        return foodRepository.save(food);
    }

    public void deleteFood(Long id) {
        Food food = getFoodById(id);
        foodRepository.delete(food);
    }
}

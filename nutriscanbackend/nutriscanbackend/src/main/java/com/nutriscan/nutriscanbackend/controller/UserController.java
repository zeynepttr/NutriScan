package com.nutriscan.nutriscanbackend.controller;

import com.nutriscan.nutriscanbackend.DTO.UserResponse;
import com.nutriscan.nutriscanbackend.DTO.UserUpdateRequest;
import com.nutriscan.nutriscanbackend.entity.Food;
import com.nutriscan.nutriscanbackend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getProfile() {
        return ResponseEntity.ok(userService.getProfile());
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponse> updateProfile(@RequestBody UserUpdateRequest request) {
        return ResponseEntity.ok(userService.updateProfile(request));
    }

    @DeleteMapping("/me")
    public ResponseEntity<Void> deleteAccount() {
        userService.deleteAccount();
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me/saved-foods")
    public ResponseEntity<List<Food>> getSavedFoods() {
        return ResponseEntity.ok(userService.getSavedFoods());
    }

    @PostMapping("/me/saved-foods/{foodId}")
    public ResponseEntity<Void> saveFood(@PathVariable Long foodId) {
        userService.saveFood(foodId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/me/saved-foods/{foodId}")
    public ResponseEntity<Void> removeFood(@PathVariable Long foodId) {
        userService.removeFood(foodId);
        return ResponseEntity.ok().build();
    }
}

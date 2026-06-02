package com.nutriscan.nutriscanbackend.service;

import com.nutriscan.nutriscanbackend.DTO.UserResponse;
import com.nutriscan.nutriscanbackend.DTO.UserUpdateRequest;
import com.nutriscan.nutriscanbackend.entity.Food;
import com.nutriscan.nutriscanbackend.entity.User;
import com.nutriscan.nutriscanbackend.repository.FoodRepository;
import com.nutriscan.nutriscanbackend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final FoodRepository foodRepository;

    private User getAuthenticatedUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + email));
    }

    public UserResponse getProfile() {
        User user = getAuthenticatedUser();
        return mapToUserResponse(user);
    }

    public UserResponse updateProfile(UserUpdateRequest request) {
        User user = getAuthenticatedUser();
        if (request.getFirstName() != null) {
            user.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            user.setLastName(request.getLastName());
        }
        if (request.getAge() != null) {
            user.setAge(request.getAge());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }
        User updatedUser = userRepository.save(user);
        return mapToUserResponse(updatedUser);
    }

    public void deleteAccount() {
        User user = getAuthenticatedUser();
        userRepository.delete(user);
    }

    @Transactional(readOnly = true)
    public List<Food> getSavedFoods() {
        User user = getAuthenticatedUser();
        // Trigger lazy-loading explicitly if needed, but since it is @ManyToMany it depends. We fetch it within transaction.
        return List.copyOf(user.getSavedFoods());
    }

    @Transactional
    public void saveFood(Long foodId) {
        User user = getAuthenticatedUser();
        Food food = foodRepository.findById(foodId)
                .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + foodId));
        
        if (!user.getSavedFoods().contains(food)) {
            user.getSavedFoods().add(food);
            userRepository.save(user);
        }
    }

    @Transactional
    public void removeFood(Long foodId) {
        User user = getAuthenticatedUser();
        Food food = foodRepository.findById(foodId)
                .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + foodId));
        
        if (user.getSavedFoods().contains(food)) {
            user.getSavedFoods().remove(food);
            userRepository.save(user);
        }
    }

    private UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .age(user.getAge())
                .gender(user.getGender())
                .email(user.getEmail())
                .build();
    }
}

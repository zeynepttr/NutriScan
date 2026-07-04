package com.nutriscan.nutriscanbackend.controller;

import com.nutriscan.nutriscanbackend.DTO.AuthResponse;
import com.nutriscan.nutriscanbackend.DTO.LoginRequest;
import com.nutriscan.nutriscanbackend.DTO.RegisterRequest;
import com.nutriscan.nutriscanbackend.DTO.UserResponse;
import com.nutriscan.nutriscanbackend.config.JwtService;
import com.nutriscan.nutriscanbackend.entity.User;
import com.nutriscan.nutriscanbackend.repository.UserRepository;
import com.nutriscan.nutriscanbackend.service.LlmCalorieService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final LlmCalorieService llmCalorieService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email is already registered");
        }

        // Validate weight goal safety limits
        Double requestWeight = request.getWeight() != null ? request.getWeight() : 70.0;
        String requestTarget = request.getTarget() != null ? request.getTarget() : "MAINTAIN";
        LlmCalorieService.validateWeightGoal(requestWeight, requestTarget, request.getTargetWeight(), request.getTargetDays());

        User user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setAge(request.getAge());
        user.setGender(request.getGender());
        user.setWeight(request.getWeight());
        user.setHeight(request.getHeight());
        user.setTarget(request.getTarget());
        user.setTargetWeight(request.getTargetWeight());
        user.setTargetDays(request.getTargetDays());
        user.setAllergens(request.getAllergens() != null ? request.getAllergens() : new java.util.ArrayList<>());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        // Calculate and set daily calorie goal using LLM/fallback
        int age = request.getAge() != null ? request.getAge() : 25;
        String gender = request.getGender() != null ? request.getGender() : "MALE";
        double weight = request.getWeight() != null ? request.getWeight() : 70.0;
        double height = request.getHeight() != null ? request.getHeight() : 175.0;
        String target = request.getTarget() != null ? request.getTarget() : "MAINTAIN";

        int dailyCalorieTarget = llmCalorieService.calculateCalories(age, gender, weight, height, target, request.getTargetWeight(), request.getTargetDays());
        user.setDailyCalorieTarget(dailyCalorieTarget);

        User savedUser = userRepository.save(user);
        String jwtToken = jwtService.generateToken(savedUser);

        UserResponse userResponse = UserResponse.builder()
                .id(savedUser.getId())
                .firstName(savedUser.getFirstName())
                .lastName(savedUser.getLastName())
                .age(savedUser.getAge())
                .gender(savedUser.getGender())
                .weight(savedUser.getWeight())
                .height(savedUser.getHeight())
                .target(savedUser.getTarget())
                .targetWeight(savedUser.getTargetWeight())
                .targetDays(savedUser.getTargetDays())
                .dailyCalorieTarget(savedUser.getDailyCalorieTarget())
                .email(savedUser.getEmail())
                .allergens(savedUser.getAllergens())
                .build();

        return ResponseEntity.ok(AuthResponse.builder()
                .token(jwtToken)
                .user(userResponse)
                .build());
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        String jwtToken = jwtService.generateToken(user);

        UserResponse userResponse = UserResponse.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .age(user.getAge())
                .gender(user.getGender())
                .weight(user.getWeight())
                .height(user.getHeight())
                .target(user.getTarget())
                .targetWeight(user.getTargetWeight())
                .targetDays(user.getTargetDays())
                .dailyCalorieTarget(user.getDailyCalorieTarget())
                .email(user.getEmail())
                .allergens(user.getAllergens())
                .build();

        return ResponseEntity.ok(AuthResponse.builder()
                .token(jwtToken)
                .user(userResponse)
                .build());
    }
}

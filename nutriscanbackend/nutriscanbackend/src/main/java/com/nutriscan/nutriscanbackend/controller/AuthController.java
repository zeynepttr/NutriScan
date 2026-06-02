package com.nutriscan.nutriscanbackend.controller;

import com.nutriscan.nutriscanbackend.DTO.AuthResponse;
import com.nutriscan.nutriscanbackend.DTO.LoginRequest;
import com.nutriscan.nutriscanbackend.DTO.RegisterRequest;
import com.nutriscan.nutriscanbackend.DTO.UserResponse;
import com.nutriscan.nutriscanbackend.config.JwtService;
import com.nutriscan.nutriscanbackend.entity.User;
import com.nutriscan.nutriscanbackend.repository.UserRepository;
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

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new IllegalArgumentException("Email is already registered");
        }

        User user = new User();
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setAge(request.getAge());
        user.setGender(request.getGender());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        User savedUser = userRepository.save(user);
        String jwtToken = jwtService.generateToken(savedUser);

        UserResponse userResponse = UserResponse.builder()
                .id(savedUser.getId())
                .firstName(savedUser.getFirstName())
                .lastName(savedUser.getLastName())
                .age(savedUser.getAge())
                .gender(savedUser.getGender())
                .email(savedUser.getEmail())
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
                .email(user.getEmail())
                .build();

        return ResponseEntity.ok(AuthResponse.builder()
                .token(jwtToken)
                .user(userResponse)
                .build());
    }
}
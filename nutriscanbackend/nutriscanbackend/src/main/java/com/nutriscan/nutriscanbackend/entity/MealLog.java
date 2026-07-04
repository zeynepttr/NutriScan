package com.nutriscan.nutriscanbackend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "meal_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private String foodName;

    private float calories;
    private float fat;
    private float protein;
    private float carbohydrate;
    private float confidence;

    private boolean containsAllergen;
    private String allergenWarning;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}

package com.nutriscan.nutriscanbackend.repository;

import com.nutriscan.nutriscanbackend.entity.Food;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FoodRepository extends JpaRepository<Food, Long> {
    List<Food> findByNameContainingIgnoreCase(String name);
}
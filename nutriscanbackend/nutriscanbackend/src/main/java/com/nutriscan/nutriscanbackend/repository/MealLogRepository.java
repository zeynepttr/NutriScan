package com.nutriscan.nutriscanbackend.repository;

import com.nutriscan.nutriscanbackend.entity.MealLog;
import com.nutriscan.nutriscanbackend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface MealLogRepository extends JpaRepository<MealLog, Long> {
    List<MealLog> findByUserAndDateOrderByCreatedAtDesc(User user, LocalDate date);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Base & Backgrounds (Light theme)
  static const Color darkBg = Color(0xFFF8FAFC);       
  static const Color cardBg = Color(0xFFFFFFFF);       
  static const Color surfaceBg = Color(0xFFF1F5F9);    

  // Brand Identity (Sporty fresh greens & vibrant appetizing orange)
  static const Color primaryGreen = Color(0xFF10B981);  
  static const Color mintGreen = Color(0xFFD1FAE5);     
  static const Color activeOrange = Color(0xFFF97316);  

  // Macro Nutrient Colors (Sporty, vibrant)
  static const Color proteinBlue = Color(0xFF3A86FF);   
  static const Color carbYellow = Color(0xFFFFBE0B);    
  static const Color fatPink = Color(0xFFFF006E);       
  static const Color waterBlue = Color(0xFF00B4D8);     

  // Typography & Status (Dark on Light)
  static const Color textPrimary = Color(0xFF0F172A);   
  static const Color textSecondary = Color(0xFF64748B); 
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient healthGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calorieGradient = LinearGradient(
    colors: [activeOrange, Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.darkBg,
      
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        secondary: AppColors.activeOrange,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.cardBg,
        onSurface: AppColors.textPrimary,
      ),

      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        baseTextTheme.copyWith(
          displayLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          displayMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          headlineLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          titleMedium: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
          bodyLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          bodyMedium: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          labelLarge: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white, 
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          elevation: 0,
        ),
      ),
    );
  }
}
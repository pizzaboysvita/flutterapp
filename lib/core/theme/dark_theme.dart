import 'package:flutter/material.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class AppTheme {
  static ThemeData get darkFuturistic {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.redPrimary,
      scaffoldBackgroundColor: Colors.transparent, // Important for gradient
      colorScheme: const ColorScheme.dark(
        primary: AppColors.redPrimary,
        secondary: AppColors.redSecondary,
        surface: Color(0xFF1C1C1C),
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardColor: const Color(0xFF2B2B2B),
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          backgroundColor: AppColors.redPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: Colors.grey[800],
    );
  }
}

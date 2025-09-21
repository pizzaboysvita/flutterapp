import 'package:flutter/material.dart';

class AppColors {
  // App Theme Colors
  static const Color scaffoldColor = Color(0xFFF8F8F8);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static Color secondaryBlack = Colors.black.withOpacity(0.6);

  // Red Theme Shades
  static const Color redPrimary = Color(0xFFB71C1C); 
  static const Color redSecondary = Color(
    0xFFD32F2F,
  ); // Gradient Secondary Color
  static const Color redAccent = Color(0Xffe71512);

  static const Color greenColor = Colors.green;

  // Banner Gradient (Black to Red)
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [blackColor, redPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Button Gradient (Red Primary to Red Secondary)
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [redPrimary, redSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category Background Colors (Soft Pastels)
  static const Color categoryOrange = Color(0xFFFFF3E0); // Light Orange
  static const Color categoryGreen = Color(0xFFE6FCF0); // Light Green
  static const Color categoryYellow = Color(0xFFFFF8E1); // Light Yellow
  static const Color categoryPink = Color(0xFFFFEBEE); // Soft Pink

  // Icon Colors
  static const Color ratingYellow = Colors.amber; //Rating Color
  static const Color vitaColor = Color(0xff43AD31);
}

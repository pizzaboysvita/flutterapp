import 'package:flutter/material.dart';

class AppColors {
  // App Theme Colors
  static const Color scaffoldColorLight = Color(
    0xFFF5F5F5,
  ); // Light Mode background
  static const Color scaffoldColorDark = Color(
    0xFF212121,
  ); // Dark Mode background

  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  static const Color secondaryBlackLight = Colors.black54;
  static const Color secondaryBlackDark = Colors.white70;

  // Red Theme Shades
  static const Color redPrimary = Color(0xFFB71C1C);
  static const Color redSecondary = Color(0xFFD32F2F);
  static const Color redAccent = Color(0xFFE71512);

  static const Color greenColor = Colors.green;

  // Banner Gradient (Black to Red)
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Colors.black, redPrimary],
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
  static const Color ratingYellow = Colors.amber; // Rating color
  static const Color vitaColor = Color(0xff43AD31);

  // Adaptive Colors
  static Color scaffoldColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? scaffoldColorDark
        : scaffoldColorLight;
  }

  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? whiteColor
        : blackColor;
  }

  static Color secondaryBlack(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondaryBlackDark
        : secondaryBlackLight;
  }

  static Color dotActive(BuildContext context) {
    return redAccent;
  }

  static Color dotInactive(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white30
        : Colors.black26;
  }

  // ✅ New adaptive color functions for conditions
  static Color activeTextColor(BuildContext context) {
    return Colors.deepOrange; // stays same, but you can change if needed
  }

  static Color inactiveTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
  }

  static Color categoryTextColor(BuildContext context, bool isActive) {
    return isActive ? activeTextColor(context) : inactiveTextColor(context);
  }

  static Color borderColor(BuildContext context, bool isActive) {
    return isActive
        ? Colors.deepOrange
        : Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black26;
  }

  static Color bottomCurveColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]! // Dark mode grey
        : Colors.black; // Light mode black
  }
}

import 'package:flutter/material.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class DefaultTheme {
  /// ✅ Light Theme
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.from(
      useMaterial3: true,
      textTheme: _textTheme(),
      colorScheme: _colorScheme(brightness: Brightness.light),
    );

    final colorScheme = baseTheme.colorScheme;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldColorLight,
      appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(colorScheme: colorScheme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(MaterialState.disabled)) {
              return const BorderSide(color: Colors.grey, width: 1.5);
            }
            return const BorderSide(color: Colors.black, width: 2);
          }),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade200;
            }
            return Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            }
            return Colors.black;
          }),
        ),
      ),
    );
  }

  /// ✅ Dark Theme
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.from(
      useMaterial3: true,
      textTheme: _textTheme(),
      colorScheme: _colorScheme(brightness: Brightness.dark),
    );

    final colorScheme = baseTheme.colorScheme;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldColorDark,
      appBarTheme: const AppBarTheme(elevation: 0, scrolledUnderElevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(colorScheme: colorScheme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(color: Colors.white.withOpacity(0.8), width: 2),
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
    );
  }

  /// 🔹 Shared color scheme helper
  static ColorScheme _colorScheme({Brightness brightness = Brightness.light}) {
    return ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: AppColors.redPrimary,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
  }

  /// 🔹 Shared text theme helper
  static TextTheme _textTheme({
    String headingFont = "Poppins",
    String bodyFont = "Poppins",
  }) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontFamily: headingFont,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontFamily: headingFont,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontFamily: headingFont,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontFamily: headingFont,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontFamily: headingFont,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontFamily: headingFont,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontFamily: headingFont,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      letterSpacing: 0.5,
      fontFamily: bodyFont,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      letterSpacing: 0.25,
      fontFamily: bodyFont,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      letterSpacing: 0.4,
      fontFamily: bodyFont,
      fontWeight: FontWeight.w400,
    ),
  );

  /// 🔹 Shared button style helper
  static ButtonStyle _buttonStyle({required ColorScheme colorScheme}) =>
      ButtonStyle(
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.outline;
          } else {
            return colorScheme.primary;
          }
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return colorScheme.onSurfaceVariant;
          } else {
            return colorScheme.onPrimary;
          }
        }),
      );
}

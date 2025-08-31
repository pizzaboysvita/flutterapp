import 'package:flutter/material.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class DefaultTheme {
  static get defaultTheme {
    final baseTheme = ThemeData.from(
      useMaterial3: true,
      textTheme: _textTheme(),
      colorScheme: _colorScheme(),
    );

    final colorScheme = baseTheme.colorScheme;
    final textTheme = baseTheme.textTheme;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldColor,
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
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.outline;
            } else {
              return colorScheme.primary;
            }
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurfaceVariant;
            } else {
              return colorScheme.onPrimary;
            }
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(MaterialState.disabled)) {
              return BorderSide(color: Colors.grey, width: 1.5);
            }
            return BorderSide(color: Colors.black, width: 2);
          }),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
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

  static ColorScheme _colorScheme({Brightness brightness = Brightness.light}) {
    return ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: AppColors.redPrimary,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
  }

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
    titleMedium: TextStyle(
      fontSize: 16,
      letterSpacing: 0.15,
      fontFamily: headingFont,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      letterSpacing: 0.1,
      fontFamily: headingFont,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      letterSpacing: 0.1,
      fontFamily: bodyFont,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      letterSpacing: 0.5,
      fontFamily: bodyFont,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      letterSpacing: 0.5,
      fontFamily: bodyFont,
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

  static ButtonStyle _buttonStyle({required ColorScheme colorScheme}) =>
      ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.outline;
          } else {
            return colorScheme.primary;
          }
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurfaceVariant;
          } else {
            return colorScheme.onPrimary;
          }
        }),
      );
}

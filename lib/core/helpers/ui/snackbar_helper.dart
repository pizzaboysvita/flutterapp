import 'package:flutter/material.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.redPrimary,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🔹 Predefined Snackbar styles
  static void red(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.redPrimary,
      textColor: Colors.white,
    );
  }

  static void black(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  static void green(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static void white(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
  }
}

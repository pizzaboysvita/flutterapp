import 'package:flutter/material.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';

class SessionManager {
  static Future<void> checkSession(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    if (ErrorScreenTracker.isShowing) {
      debugPrint("⚠️ Error screen is showing. Skipping session navigation.");
      return; // Prevent overlapping navigation
    }

    final token = await TokenStorage.getAccessToken();
    debugPrint("🔍 Token: $token");

    if (token == null || token.isEmpty) {
      debugPrint("🆕 No token found. Navigating to landing.");
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.landing);
      }
      return;
    }

    final chosenLocation = await TokenStorage.getChosenLocation();
    debugPrint("🔍 Chosen Location: $chosenLocation");

    if (chosenLocation == null || chosenLocation.isEmpty) {
      debugPrint("✅ Location not chosen. Navigating to ChooseStoreLocation.");
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.chooseStoreLocation);
      }
    } else {
      debugPrint("🎉 Session OK. Navigating to Home.");
   if (!ErrorScreenTracker.isShowing) {
  Navigator.pushReplacementNamed(context, AppRoutes.home);
}

    }
  }

  static Future<void> clearSession(BuildContext context) async {
    await TokenStorage.clearSession();
    debugPrint("🚪 Session cleared. Redirecting to Login.");
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}

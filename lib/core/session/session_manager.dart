import 'package:flutter/material.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class SessionManager {
  static Future<void> checkSession(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      debugPrint("🆕 User is fresh (no token). Navigating to landing.");
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
      return;
    }

    final chosenLocation = await TokenStorage.getChosenLocation();
    if (chosenLocation == null || chosenLocation.isEmpty) {
      debugPrint("✅ User logged in but has NOT chosen a location. Going to ChooseStoreLocation.");
      Navigator.pushReplacementNamed(context, AppRoutes.chooseStoreLocation);
    } else {
      debugPrint("🎉 User logged in and location chosen. Going to Home.");
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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

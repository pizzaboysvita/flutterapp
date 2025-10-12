import 'package:flutter/material.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';

class SessionManager {
  static Future<void> checkSession(BuildContext context) async {
    if (!context.mounted) return;

    if (ErrorScreenTracker.isShowing) {
      return;
    }

    // ✅ Check if first time app launch
    final isFirstLaunch = await TokenStorage.getIsFirstLaunch();
    if (isFirstLaunch) {
      await TokenStorage.setIsFirstLaunch(false); // mark first launch complete
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.landing);
      }
      return;
    }

    // ✅ Check if location is chosen
    final isLocationChosen = await TokenStorage.isLocationChosen();
    if (!isLocationChosen) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.chooseStoreLocation);
      }
      return;
    }

    // ✅ Check if user is logged in
    final token = await TokenStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    // ✅ Everything is fine → go to Home

    if (context.mounted && !ErrorScreenTracker.isShowing) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  static Future<void> clearSession(BuildContext context) async {
    await TokenStorage.clearSession();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}

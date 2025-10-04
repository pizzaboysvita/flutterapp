import 'package:flutter/material.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';

class SessionManager {
static Future<void> checkSession(BuildContext context) async {

  if (!context.mounted) return;

  if (ErrorScreenTracker.isShowing) {
    debugPrint("⚠️ Error screen is showing. Skipping session navigation.");
    return;
  }

  // ✅ Check if first time app launch
  final isFirstLaunch = await TokenStorage.getIsFirstLaunch();
  if (isFirstLaunch) {
    debugPrint("🆕 First launch detected. Navigating to Landing.");
    await TokenStorage.setIsFirstLaunch(false); // mark first launch complete
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.landing);
    }
    return;
  }

  // ✅ Check if location is chosen
  final isLocationChosen = await TokenStorage.isLocationChosen();
  if (!isLocationChosen) {
    debugPrint("📍 Location not chosen. Navigating to ChooseStoreLocation.");
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.chooseStoreLocation);
    }
    return;
  }

  // ✅ Check if user is logged in
  final token = await TokenStorage.getAccessToken();
  debugPrint("🔍 Token: $token");

  if (token == null || token.isEmpty) {
    debugPrint("🔑 Location chosen but not logged in. Navigating to Login.");
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
    return;
  }

  // ✅ Everything is fine → go to Home
  debugPrint("🎉 Session OK. Navigating to Home.");
  if (context.mounted && !ErrorScreenTracker.isShowing) {
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

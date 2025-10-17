import 'package:pizza_boys/core/helpers/api_client_helper.dart';

class ApiHealthChecker {
  static Future<bool> checkServerHealth() async {
    try {
      final response = await ApiClient.dio.get("healthCheck");

      print("🩺 [ApiHealth] Response: ${response.data}");

      // handle both server error codes and your custom error response
      if (response.statusCode == 500 ||
          (response.data is Map && response.data["code"] == 0)) {
        return false;
      }

      return true;
    } catch (e) {
      print("❌ [ApiHealth] Exception: $e");
      return false;
    }
  }
}

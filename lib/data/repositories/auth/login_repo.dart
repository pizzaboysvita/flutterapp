import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/services/auth/login_service.dart';

class LoginRepo {
  final LoginService _service = LoginService();

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final data = await _service.postLogin(email, password);

    return data;
  }

  // Guest Flow
  Future<void> guestLogin() async {
    try {
      print("👤 [AuthRepository] Starting guest login...");

      // 🔹 API endpoint for guest token
      const endpoint = "refreshToken";

      // 🔹 Request payload
      final body = {"guest": true};

      // 🔹 Send request using ApiClient.dio
      final response = await ApiClient.dio.post(
        endpoint,
        data: jsonEncode(body),
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("📡 [AuthRepository] Response: ${response.statusCode}");
      print("🧾 Data: ${response.data}");

      if (response.statusCode == 200 && response.data["code"] == 1) {
        final guestToken = response.data["access_token"];
        final user = response.data["user"];

        await TokenStorage.saveGuestSession(guestToken);
        print("✅ [AuthRepository] Guest login success → token: $guestToken");
        print("👤 User Info → $user");
      } else {
        print("❌ [AuthRepository] Guest login failed → ${response.data}");
        throw Exception(
          "Guest login failed: ${response.data["message"] ?? "Unknown error"}",
        );
      }
    } on DioException catch (e) {
      print("🚨 [AuthRepository] DioException during guest login:");
      print("🔸 Type: ${e.type}");
      print("🔸 Message: ${e.message}");
      print("🔸 Response: ${e.response?.data}");
      rethrow;
    } catch (e, s) {
      print("❌ [AuthRepository] Guest login error: $e");
      print("🧩 Stack: $s");
      rethrow;
    }
  }
}

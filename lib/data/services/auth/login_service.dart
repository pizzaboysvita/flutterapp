import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class LoginService {
  Future<Map<String, dynamic>> postLogin(String email, String password) async {
    print("🔐 Attempting login for email: $email");

    try {
      final response = await ApiClient.dio.post(
        ApiUrls.loginPost,
        data: {
          "email": email,
          "password_hash": password,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      print('✅ Login API Response Code: ${response.statusCode}');
      print('📥 Login API Response Body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = response.data;

        // ✅ Save user session (tokens, user info)
        await TokenStorage.saveSession(data);

        print('🎉 Login data saved to storage');

        return data;
      } else {
        print("⚠️ Login failed with status code: ${response.statusCode}");
        throw Exception('Failed to login user');
      }
    } on DioException catch (e) {
      print("❌ DioException during login: ${e.message}");
      throw Exception('Login request failed: ${e.message}');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/error_handling_helper.dart';

class LoginService {
  Future<Map<String, dynamic>> postLogin(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        ApiUrls.loginPost,
        data: {"email": email, "password_hash": password},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final Map<String, dynamic> data = response.data;

      // ✅ Return API data and let Bloc decide
      return data;
    } catch (error) {
      final msg = ApiErrorHandler.handle(
        error,
        fallbackMessage: "Login failed",
      );

      // ✅ Instead of throw — return failure map
      return {"code": 0, "message": msg};
    }
  }
}

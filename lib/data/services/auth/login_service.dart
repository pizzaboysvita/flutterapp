import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/error_handling_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class LoginService {
  Future<Map<String, dynamic>> postLogin(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        ApiUrls.loginPost,
        data: {"email": email, "password_hash": password},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final Map<String, dynamic> data = response.data;

      // Handle backend success/failure
      if (data["code"] == 1) {
        await TokenStorage.saveSession(data);
      }

      return data; // return backend response (success/failure)
    } catch (error) {
      final msg = ApiErrorHandler.handle(
        error,
        fallbackMessage: "Login failed",
      );
      throw Exception(msg);
    }
  }
}

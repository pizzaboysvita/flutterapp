import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';

class LoginService {
  Future<Map<String, dynamic>> postLogin(String email, String password) async {
    print("Attempting login for email: $email"); // Debug log
    final response = await http.post(
      Uri.parse(ApiUrls.loginPost),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password_hash": password,
      }),
    );

    print('User Login Details : $email , $password');
    print('Login API Response Code: ${response.statusCode}');
    print('Login API Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      print("Login failed with status code: ${response.statusCode}");
      throw Exception('Failed to Login User');
    }
  }
}


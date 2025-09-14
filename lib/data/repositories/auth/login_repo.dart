import 'package:pizza_boys/data/services/auth/login_service.dart';

class LoginRepo {
  final LoginService _service = LoginService();

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final data = await _service.postLogin(email, password);
      print('Login Repo Data : $data');
      print("LoginRepo: loginUser called with email: $email");
      return data;
    } catch (e) {
      throw Exception('Login Failed at repo : $e');
    }
  }
}

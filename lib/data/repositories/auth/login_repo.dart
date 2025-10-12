import 'package:pizza_boys/data/services/auth/login_service.dart';

class LoginRepo {
  final LoginService _service = LoginService();

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final data = await _service.postLogin(email, password);

    return data;
  }
}

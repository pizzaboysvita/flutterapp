import 'dart:io';

import 'package:pizza_boys/data/services/auth/register_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String country,
    required String state,
    required String city,
    required int pinCode,
    File? imageFile,
  }) {
    return _service.registerUser(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      address: address,
      country: country,
      state: state,
      city: city,
      pinCode: pinCode,
      imageFile: imageFile,
    );
  }
}

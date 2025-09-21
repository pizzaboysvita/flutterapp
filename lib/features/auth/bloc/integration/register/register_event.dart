import 'dart:io';
import 'dart:ui';

abstract class RegisterEvent {}

class SubmitRegister extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;
  final String address;
  final String country;
  final String state;
  final String city;
  final int pinCode;
  final File? imageFile;
  final VoidCallback? onSuccess;

  SubmitRegister({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.pinCode,
    this.imageFile,
    this.onSuccess,

  });
}

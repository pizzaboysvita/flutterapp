import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';

class UserService {
  Future<Response> updateUser(FormData formData) async {
    return await ApiClient.dio.post(
      "userv2",
      data: formData,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class UserRepo {
  Future<Response> deleteUserAccount() async {
    final userId = await TokenStorage.getUserId();

    debugPrint("🧑 USER ID: $userId");

    if (userId == null || userId.isEmpty) {
      debugPrint("❌ User ID not found");
      throw Exception("User ID not found");
    }

    final endpoint = "user/$userId";
    debugPrint("🚀 DELETE API → $endpoint");

    try {
      final response = await ApiClient.dio.delete(endpoint);

      debugPrint("✅ STATUS CODE: ${response.statusCode}");
      debugPrint("📦 RESPONSE DATA: ${response.data}");

      return response;
    } on DioException catch (e) {
      debugPrint("❌ API ERROR");
      debugPrint("STATUS: ${e.response?.statusCode}");
      debugPrint("DATA: ${e.response?.data}");
      debugPrint("MESSAGE: ${e.message}");

      rethrow;
    }
  }
}

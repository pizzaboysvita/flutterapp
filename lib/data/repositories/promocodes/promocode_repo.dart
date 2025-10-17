import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';


class PromoRepository {
  Future<List<Map<String, dynamic>>> fetchPromos(int storeId) async {
    try {
      final token = await TokenStorage.getAccessToken(); // Get stored token

      final response = await ApiClient.dio.get(
        "promocode",
        queryParameters: {"store_id": storeId},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200 && response.data["code"] == 1) {
        final List data = response.data["data"];
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception("Failed to load promo codes");
      }
    } on DioException catch (e) {
      print("🚨 PromoRepository Error: ${e.response?.data}");
      rethrow;
    }
  }
}

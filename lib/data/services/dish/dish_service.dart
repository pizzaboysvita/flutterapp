import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';

class DishService {
  Future<List<dynamic>> fetchAllDishes() async {
    try {
      final dishUrl = await ApiUrls.getDishUrl();
      print("🔗 Fetching dishes from URL: $dishUrl");
      final response = await ApiClient.dio.get(dishUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data'] ?? [];
      } else {
        throw Exception("Failed to load dishes: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("DishService Error: ${e.message}");
    }
  }
}

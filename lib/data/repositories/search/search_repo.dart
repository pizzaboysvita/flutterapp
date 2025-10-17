import 'package:pizza_boys/core/helpers/api_client_helper.dart';

class SearchRepo {
  Future<List<Map<String, dynamic>>> searchDishes({
    required int storeId,
    required String query,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        "dish/search",
        queryParameters: {
          "store_id": storeId,
          "dish_name": query,
          "type": "web",
        },
      );

      if (response.statusCode == 200 && response.data["code"] == "1") {
        final data = response.data["data"] as List;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception(response.data["messageSet"]["message"] ?? "Search failed");
      }
    } catch (e, s) {
      print("❌ [SearchRepo] Error: $e");
      print(s);
      rethrow;
    }
  }
}

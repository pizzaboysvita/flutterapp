import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

class FavoriteService {
  // Fav Post
  Future<bool> toggleFavorite({
    required int dishId,
    required String token,
  }) async {
    final url = Uri.parse(ApiUrls.whishlist);
    // ✅ Fetch userId and storeId from TokenStorage
    final userIdStr = await TokenStorage.getUserId();
    final storeIdStr = await TokenStorage.getChosenStoreId();

    if (userIdStr == null || storeIdStr == null) {
      throw Exception("User ID or Store ID is not available.");
    }

    final userId = int.parse(userIdStr);
    final storeId = int.parse(storeIdStr);

    print("FavoriteService: Sending request");
    print("URL: $url");
    print("User ID: $userId, Dish ID: $dishId, Store ID: $storeId");
    print("Token: $token");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final body = jsonEncode({
      "user_id": userId,
      "dish_id": dishId,
      "store_id": storeId,
    });

    print("Request Body: $body");

    final response = await http.post(url, headers: headers, body: body);

    print("FavoriteService: Response = ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      print("Failed with status code: ${response.statusCode}");
      throw Exception('Failed to toggle favorite');
    }
  }

  // Fav Get
  Future<List<DishModel>> getWishlist({required String token}) async {
    final userIdStr = await TokenStorage.getUserId();
    if (userIdStr == null) {
      throw Exception("User ID not available.");
    }
    final url = Uri.parse('${ApiUrls.whishlist}?user_id=$userIdStr');
    print("📡 Fetching wishlist from $url");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final response = await http.get(url, headers: headers);
    print("📥 Response code: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final List<dynamic> data = jsonData['data']; // Extract 'data' key
      return data.map((json) {
        return DishModel.fromWishlistJson(json);
      }).toList();
    } else {
      throw Exception('Failed to load wishlist: ${response.statusCode}');
    }
  }
}

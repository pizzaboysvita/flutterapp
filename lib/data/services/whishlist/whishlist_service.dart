import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';

class FavoriteService {
  // ✅ Toggle favorite (add)
  Future<bool> toggleFavorite({required int dishId}) async {
    final userIdStr = await TokenStorage.getUserId();
    final storeIdStr = await TokenStorage.getChosenStoreId();

    if (userIdStr == null || storeIdStr == null) {
      throw Exception("User ID or Store ID not available.");
    }

    final body = {
      "type": "insert",
      "user_id": int.parse(userIdStr),
      "dish_id": dishId,
      "store_id": int.parse(storeIdStr),
    };

    print("FavoriteService: POST ${ApiUrls.wishlist}");
    print("Body: $body");

    try {
      final response = await ApiClient.dio.post(ApiUrls.wishlist, data: body);
      print("Response: ${response.data}");

      return response.data['success'] == true;
    } catch (e) {
      print("FavoriteService: toggleFavorite error: $e");
      throw Exception("Failed to toggle favorite");
    }
  }

  // ✅ Remove favorite
  Future<bool> removeFavorite({
    required int dishId,
    int? wishlistId, // optional wishlist id
  }) async {
    final userIdStr = await TokenStorage.getUserId();
    final storeIdStr = await TokenStorage.getChosenStoreId();

    if (userIdStr == null || storeIdStr == null) {
      throw Exception("User ID or Store ID not available.");
    }

    final body = {
      "type": "delete",
      "user_id": int.parse(userIdStr),
      "dish_id": dishId,
      "store_id": int.parse(storeIdStr),
      "wishlist_id": wishlistId,
    };

    print("FavoriteService: DELETE (POST) ${ApiUrls.wishlist}");
    print("Body: $body");

    try {
      final response = await ApiClient.dio.post(ApiUrls.wishlist, data: body);
      print("Response: ${response.data}");

      return response.data['success'] == true;
    } catch (e) {
      print("FavoriteService: removeFavorite error: $e");
      throw Exception("Failed to remove favorite");
    }
  }

  // ✅ Get wishlist
  Future<List<DishModel>> getWishlist() async {
    final userIdStr = await TokenStorage.getUserId();
    if (userIdStr == null) throw Exception("User ID not available.");

    final url = "${ApiUrls.wishlist}?user_id=$userIdStr";
    print("FavoriteService: GET $getWishlist");

    try {
      final response = await ApiClient.dio.get(url);
      print("Response: ${response.data}");

      final List<dynamic> data = response.data['data'];
      return data.map((json) => DishModel.fromJson(json)).toList();
    } catch (e) {
      print("FavoriteService: getWishlist error: $e");
      throw Exception("Failed to load wishlist");
    }
  }
}

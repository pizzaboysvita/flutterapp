import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';

class CartService {
  final Dio _dio = ApiClient.dio; // use your singleton Dio client

  // 🛒 Add to Cart
  Future<Map<String, dynamic>> addToCart({
    required String type,
    required int userId,
    required int dishId,
    required int storeId,
    required int quantity,
    required double price,
    required String optionsJson,
  }) async {
    final body = {
      "type": type,
      "user_id": userId,
      "dish_id": dishId,
      "store_id": storeId,
      "quantity": quantity,
      "price": price,
      "options_json": optionsJson,
    };

    try {
      

      final response = await ApiClient.dio.post("cart", data: body);

      
      

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      
      throw Exception(
        "Failed to add to cart: ${e.response?.data ?? e.message}",
      );
    }
  }

  // 🗑 Remove from Cart
  Future<Map<String, dynamic>> removeFromCart({
    required int cartId,
    required int userId,
  }) async {
    final body = {"type": "delete_item", "cart_id": cartId, "user_id": userId};

    try {
      

      final response = await ApiClient.dio.post("cart", data: body);

      
      

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      
      throw Exception(
        "Failed to remove item: ${e.response?.data ?? e.message}",
      );
    }
  }

  // 📦 Get Cart Items
 Future<List<CartItem>> getCartItems() async {
  final userIdString = await TokenStorage.getUserId();
  if (userIdString == null) throw Exception("❌ No user ID found.");
  final userId = int.tryParse(userIdString) ?? 0;

  try {
    final response = await ApiClient.dio.get(
      "cart",
      queryParameters: {"user_id": userId},
    );

    final decoded = response.data;

    // ✅ Handle both single object and list
    List<CartItem> cartItems;
    if (decoded is List) {
      cartItems = decoded.map((e) => CartItem.fromJson(e)).toList();
    } else if (decoded is Map<String, dynamic>) {
      cartItems = [CartItem.fromJson(decoded)];
    } else {
      throw Exception("Unexpected cart response: $decoded");
    }

    // 🔹 Enrich with dish info
    final dishService = DishService();

    // ✅ Get storeId before calling fetchAllDishes
    final storeIdStr = await TokenStorage.getChosenStoreId();
    final storeId = storeIdStr ?? "-1";

    final dishes = await dishService.fetchAllDishes(storeId);

    for (var item in cartItems) {
      final match = dishes.firstWhere(
        (d) => d["dish_id"] == item.dishId,
        orElse: () => {},
      );
      if (match.isNotEmpty) {
        item.dishName = match["dish_name"];
        item.dishImage = match["dish_image"];
      }
    }

    return cartItems;
  } on DioException catch (e) {
    throw Exception("Failed to load cart: ${e.response?.data ?? e.message}");
  }
}
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';

class CartService {
  final String baseUrl = "http://78.142.47.247:3003/api";

  // Cart Post
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int dishId,
    required int storeId,
    required int quantity,
    required double price,
    required String optionsJson,
  }) async {
    final url = Uri.parse("$baseUrl/cart");

    final body = {
      "user_id": userId,
      "dish_id": dishId,
      "store_id": storeId,
      "quantity": quantity,
      "price": price,
      "options_json": optionsJson,
    };

    // 🔐 Read token dynamically
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      throw Exception("❌ No token found in storage. Please login again.");
    }

    // 🔎 Debug logs
    print("🛒 [CartService] POST $url");
    body.forEach((key, value) {
      print("   $key => (${value.runtimeType}) $value");
    });
    print("🔑 Token: ${token.substring(0, 15)}...");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // ✅ sending JSON
      },
      body: jsonEncode(body), // ✅ JSON encoding
    );

    print("✅ Status Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return compute(_parseCartResponse, response.body);
    } else {
      throw Exception("Failed to add to cart: ${response.body}");
    }
  }

  // Cart Get
  Future<List<CartItem>> getCartItems() async {
    final userIdString = await TokenStorage.getUserId();
    if (userIdString == null)
      // ignore: curly_braces_in_flow_control_structures
      throw Exception("❌ No user ID found. Please login again.");
    final userId = int.tryParse(userIdString) ?? 0;

    final url = Uri.parse("$baseUrl/cart?user_id=$userId");
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("❌ No token found. Please login again.");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load cart: ${response.body}");
    }

    final List<dynamic> data = jsonDecode(response.body);
    final cartItems = data.map((e) => CartItem.fromJson(e)).toList();

    // 🔹 Fetch dishes
    final dishService = DishService();
    final dishes = await dishService.fetchAllDishes();

    // 🔹 Match dish_id with dish data
    for (var item in cartItems) {
      final match = dishes.firstWhere(
        (d) => d["dish_id"] == item.dishId,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        item.dishName = match["dish_name"];
        item.dishImage = match["dish_image"]; // assuming API returns "image"
      }
    }

    return cartItems;
  }
}

/// Runs in background isolate
Map<String, dynamic> _parseCartResponse(String responseBody) {
  return jsonDecode(responseBody) as Map<String, dynamic>;
}

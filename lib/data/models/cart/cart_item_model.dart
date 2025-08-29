import 'dart:convert';
import 'package:pizza_boys/core/constant/image_urls.dart';

class CartItem {
  final int cartId;
  final int userId;
  final int dishId;
  final int storeId;
  final int quantity;
  final double price;
  final String status;
  final DateTime createdOn;
  final DateTime updatedOn;
  final Map<String, dynamic> options;

  // Temporary frontend image URL
  String imageUrl;

  // 🔹 New optional UI fields
  String? dishName;
  String? dishImage;

  CartItem({
    required this.cartId,
    required this.userId,
    required this.dishId,
    required this.storeId,
    required this.quantity,
    required this.price,
    required this.status,
    required this.createdOn,
    required this.updatedOn,
    required this.options,
    this.imageUrl = ImageUrls.cheeseLoverPizza, // default placeholder
    this.dishName,
    this.dishImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      dishId: json['dish_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      createdOn: json['created_on'] != null
          ? DateTime.parse(json['created_on'])
          : DateTime.now(),
      updatedOn: json['updated_on'] != null
          ? DateTime.parse(json['updated_on'])
          : DateTime.now(),
      options: json['options_json'] != null
          ? jsonDecode(json['options_json'])
          : {},

      // 🔹 still keep default fallback
      imageUrl: ImageUrls.cheeseLoverPizza, 

      // 🔹 map dishName & dishImage if backend provides them
      dishName: json['dish_name'],
      dishImage: json['dish_image'],
    );
  }
}

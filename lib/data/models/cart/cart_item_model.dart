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

  // 🔹 New fields for OrderModel
  String? base;
  double? basePrice;
  String? dishNote;

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
    this.base,
    this.basePrice,
    this.dishNote,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // 🔹 Handle options_json safely (string OR map OR null)
    Map<String, dynamic> options = {};
    if (json['options_json'] != null) {
      if (json['options_json'] is String) {
        try {
          options = jsonDecode(json['options_json']);
        } catch (e) {
          options = {};
        }
      } else if (json['options_json'] is Map<String, dynamic>) {
        options = Map<String, dynamic>.from(json['options_json']);
      }
    }

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
      options: options,

      //  fallback
      imageUrl: ImageUrls.cheeseLoverPizza,

      dishName: json['dish_name'],
      dishImage: json['dish_image'],

      base: options['base'] as String?,
      basePrice: options['basePrice'] != null
          ? double.tryParse(options['basePrice'].toString())
          : null,

      dishNote: options['dishNote'] as String?,
    );
  }
}

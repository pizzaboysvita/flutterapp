import 'dart:convert';
import 'addon_model.dart'; // 👈 import Addon

class DishModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final int dishCategoryId;
  final String description;
  final int storeId;
  final String? storeName;
  final int? wishlistId; // ✅ new field

  final List<Addon> optionSets;
  final List<Addon> ingredients;
  final List<Addon> choices;

  DishModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.dishCategoryId,
    required this.description,
    required this.storeId,
    this.storeName,
    this.wishlistId, // optional
    required this.optionSets,
    required this.ingredients,
    required this.choices,
  });

  /// 🔹 Named constructor to parse wishlist JSON
factory DishModel.fromJson(Map<String, dynamic> json) {
  double parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  return DishModel(
    id: _parseNum(json['dish_id'])?.toInt() ?? 0,
    name: "${json['dish_name']}",
    price: parsePrice(json['dish_price']),
    imageUrl: json['dish_image']?.toString() ?? "",
    rating: 0.0,
    dishCategoryId: _parseNum(json['dish_category_id'])?.toInt() ?? -1, // ✅ fix here
    description: json['description']?.toString() ?? "",
    storeId: _parseNum(json['store_id'])?.toInt() ?? 0,
    storeName: json['store_name']?.toString(),
    wishlistId: _parseNum(json['wishlist_id'])?.toInt(),
    optionSets: [], 
    ingredients: [], 
    choices: [],
  );
}

/// ✅ Converts DishModel back to JSON
Map<String, dynamic> toJson() {
  return {
    'dish_id': id,
      'dish_name': name,
      'dish_price': price,
      'dish_image': imageUrl,
      'rating': rating,
      'dish_category_id': dishCategoryId,
      'description': description,
      'store_id': storeId,
      'store_name': storeName, // optional
      'dish_option_set_json': optionSets.map((e) => e.toJson()).toList(),
      'dish_ingredients_json': ingredients.map((e) => e.toJson()).toList(),
      'dish_choices_json': choices.map((e) => e.toJson()).toList(),
    };
  }
}

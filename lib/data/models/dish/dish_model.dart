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
    required this.optionSets,
    required this.ingredients,
    required this.choices,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    List<Addon> _parseAddonList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => Addon.fromJson(e)).toList();
      }
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => Addon.fromJson(e)).toList();
          }
        } catch (_) {}
      }
      return [];
    }

    num? _parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    return DishModel(
      id: _parseNum(json['dish_id'])?.toInt() ?? 0,
      name: json['dish_name']?.toString() ?? '',
      price: _parseNum(json['dish_price'])?.toDouble() ?? 0.0,
      imageUrl: json['dish_image']?.toString() ?? '',
      rating: _parseNum(json['rating'])?.toDouble() ?? 0.0,
      dishCategoryId: _parseNum(json['dish_category_id'])?.toInt() ?? -1,
      description: json['description']?.toString() ?? '',
      storeId: _parseNum(json['store_id'])?.toInt() ?? 0,
      optionSets: _parseAddonList(json['dish_option_set_json']),
      ingredients: _parseAddonList(json['dish_ingredients_json']),
      choices: _parseAddonList(json['dish_choices_json']),
    );
  }

  /// ✅ Added toJson method
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
      'dish_option_set_json': optionSets.map((e) => e.toJson()).toList(),
      'dish_ingredients_json': ingredients.map((e) => e.toJson()).toList(),
      'dish_choices_json': choices.map((e) => e.toJson()).toList(),
    };
  }
}

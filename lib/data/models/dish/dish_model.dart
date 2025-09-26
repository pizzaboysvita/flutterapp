import 'dart:convert';
import 'addon_model.dart'; // 👈 import Addon

/// 🔹 Represents a set of options, like "Pizza Base" or "Extra Toppings"
class OptionSet {
  final String name;
  final List<Addon> options;

  OptionSet({required this.name, required this.options});

  factory OptionSet.fromJson(dynamic json) {
    Map<String, dynamic> map;
    if (json is String) {
      map = jsonDecode(json);
    } else if (json is Map<String, dynamic>) {
      map = json;
    } else {
      map = {};
    }

    final comboJson = map['option_set_combo_json'] ?? '[]';
    List<dynamic> combos = [];
    if (comboJson is String) {
      combos = jsonDecode(comboJson);
    } else if (comboJson is List) {
      combos = comboJson;
    }

    return OptionSet(
      name: map['dispaly_name'] ?? map['option_set_name'] ?? 'Option Set',
      options: combos.map((e) => Addon.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dispaly_name': name,
    'option_set_combo_json': jsonEncode(
      options.map((e) => e.toJson()).toList(),
    ),
  };
}

/// 🔹 Represents a dish/item in the menu
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
  final int? wishlistId;

  final List<OptionSet> optionSets; // ✅ Dynamic options like bases, toppings
  final List<Addon> ingredients; // ✅ Extra ingredients
  final List<Addon> choices; // ✅ Side items

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
    this.wishlistId,
    required this.optionSets,
    required this.ingredients,
    required this.choices,
  });

  /// 🔹 Parse from API JSON
  factory DishModel.fromJson(Map<String, dynamic> json) {
    List<Addon> parseAddons(dynamic jsonData) {
      if (jsonData == null) return [];
      if (jsonData is String) {
        try {
          final List<dynamic> decoded = jsonDecode(jsonData);
          return decoded.map((e) => Addon.fromJson(e)).toList();
        } catch (_) {
          return [];
        }
      } else if (jsonData is List) {
        return jsonData.map((e) => Addon.fromJson(e)).toList();
      }
      return [];
    }

    List<OptionSet> parseOptionSets(dynamic jsonData) {
      if (jsonData == null) return [];
      if (jsonData is String) {
        try {
          final List<dynamic> decoded = jsonDecode(jsonData);
          return decoded.map((e) => OptionSet.fromJson(e)).toList();
        } catch (_) {
          return [];
        }
      } else if (jsonData is List) {
        return jsonData.map((e) => OptionSet.fromJson(e)).toList();
      }
      return [];
    }

    return DishModel(
      id: json['dish_id'] ?? 0,
      name: json['dish_name'] ?? "",
      price: double.tryParse(json['dish_price']?.toString() ?? "") ?? 0.0,
      imageUrl: json['dish_image']?.toString() ?? "",
      rating: double.tryParse(json['dish_rating']?.toString() ?? "0") ?? 0.0,
      dishCategoryId: json['dish_category_id'] ?? -1,
      description: json['description'] ?? "",
      storeId: json['store_id'] ?? 0,
      storeName: json['store_name']?.toString(),
      wishlistId: json['wishlist_id'],
      optionSets: parseOptionSets(json['dish_option_set_json']),
      ingredients: parseAddons(json['dish_ingredients_json']),
      choices: parseAddons(json['dish_choices_json']),
    );
  }

  /// 🔹 Convert back to JSON
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
      'store_name': storeName,
      'wishlist_id': wishlistId,
      'dish_option_set_json': jsonEncode(
        optionSets.map((e) => e.toJson()).toList(),
      ),
      'dish_ingredients_json': jsonEncode(
        ingredients.map((e) => e.toJson()).toList(),
      ),
      'dish_choices_json': jsonEncode(choices.map((e) => e.toJson()).toList()),
    };
  }
}

extension DishModelExtensions on DishModel {
  /// Returns the "size/base" option set, if any
  OptionSet? get sizeOptionSet {
    if (optionSets.isEmpty) return null;
    return optionSets.firstWhere(
      (set) =>
          set.name.toLowerCase().contains('base') ||
          set.name.toLowerCase().contains('size'),
      orElse: () => optionSets.first,
    );
  }

  /// Returns all size options (Small, Large, etc.) as Addon list
  List<Addon> get sizes => sizeOptionSet?.options ?? [];

  /// Returns "Large" options dynamically if present
  List<Addon> get largeOptions =>
      sizes.where((e) => e.name.toLowerCase().contains('large')).toList();
}

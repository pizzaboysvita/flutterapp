import 'dart:convert';
import 'addon_model.dart'; // 👈 import Addon

/// 🔹 Represents a set of options, like "Pizza Base" or "Extra Toppings"
class OptionSet {
  final String name;
  final String optionType; // NEW
  final List<Addon> options;

  OptionSet({
    required this.name,
    required this.optionType,
    required this.options,
  });

  factory OptionSet.fromJson(dynamic json) {
    Map<String, dynamic> map;

    if (json is String) {
      try {
        map = jsonDecode(json);
      } catch (_) {
        map = {};
      }
    } else if (json is Map<String, dynamic>) {
      map = json;
    } else {
      map = {};
    }

    final comboJson = map['option_set_combo_json'] ?? '[]';
    List<dynamic> combos = [];
    if (comboJson is String) {
      try {
        combos = jsonDecode(comboJson);
      } catch (_) {
        combos = [];
      }
    } else if (comboJson is List) {
      combos = comboJson;
    }

    return OptionSet(
      name: map['dispaly_name'] ?? map['option_set_name'] ?? 'Option Set',
      optionType: map['option_type'] ?? "Radio", // Default Radio
      options: combos.map((e) => Addon.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dispaly_name': name,
      'option_type': optionType,
      'option_set_combo_json': jsonEncode(
        options.map((e) => e.toJson()).toList(),
      ),
    };
  }
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

  final List<OptionSet> optionSets; // Dynamic options like bases, toppings
  final List<Addon> ingredients; // Extra ingredients
  final List<Addon> choices; // Side items
  final List<DishModel> comboDishes; // Combo dishes (for combo type)

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
    this.comboDishes = const [],
  });

  /// 🔹 Parse from API JSON
  factory DishModel.fromJson(
    Map<String, dynamic> json, {
    List<DishModel>? allDishes,
  }) {
    print("🛠 DishModel.fromJson → Dish Type: ${json['dish_type']}");
    print("   Dish Name: ${json['dish_name']}");
    print("   Dish ID: ${json['dish_id']}");

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

    // Parse side choices
    List<Addon> comboChoices = [];
    // Parse combo dishes
    List<DishModel> comboDishes = [];
    if (json['dish_type'] == "combo" && json['dish_choices_json'] != null) {
      try {
        final choicesDecoded = jsonDecode(json['dish_choices_json']);
        for (var choice in choicesDecoded) {
          for (var menuItem in choice["menuItems"] ?? []) {
            for (var category in menuItem["categories"] ?? []) {
              for (var dishChoice in category["dishes"] ?? []) {
                comboDishes.add(
                  DishModel(
                    id: dishChoice["dishId"] ?? 0,
                    name: dishChoice["dishName"] ?? "",
                    price:
                        0.0, // 👈 you can fill from dishChoice if API gives price
                    imageUrl: dishChoice["image_url"] ?? "",
                    rating: 0.0,
                    dishCategoryId: category["categoryId"] ?? -1,
                    description: "",
                    storeId: json["store_id"] ?? 0,
                    optionSets: [],
                    ingredients: [],
                    choices: [],
                    comboDishes: [],
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        print("❗ Error parsing combo: $e");
      }
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
      optionSets: json['dish_type'] == "standard"
          ? parseOptionSets(json['dish_option_set_json'])
          : [],
      ingredients: json['dish_type'] == "standard"
          ? parseAddons(json['dish_ingredients_json'])
          : [],
      choices: comboChoices,
      comboDishes: comboDishes, // Assign parsed combo dishes
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
  OptionSet? get sizeOptionSet {
    if (optionSets.isEmpty) return null;
    return optionSets.firstWhere(
      (set) =>
          set.name.toLowerCase().contains('base') ||
          set.name.toLowerCase().contains('size'),
      orElse: () => optionSets.first,
    );
  }

  List<Addon> get sizes => sizeOptionSet?.options ?? [];

  List<Addon> get largeOptions =>
      sizes.where((e) => e.name.toLowerCase().contains('large')).toList();
}

extension DishModelExtensionsEmpty on DishModel {
  static DishModel empty() {
    return DishModel(
      id: 0,
      name: "",
      price: 0.0,
      imageUrl: "",
      rating: 0.0,
      dishCategoryId: -1,
      description: "",
      storeId: 0,
      optionSets: [],
      ingredients: [],
      choices: [],
      comboDishes: [],
    );
  }
}

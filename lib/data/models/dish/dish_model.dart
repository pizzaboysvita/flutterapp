import 'dart:convert';

class DishModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final int dishCategoryId;
  final String description;

  // ✅ Additional fields for your nested JSON
  final List<dynamic> optionSets; // Parsed from dish_option_set_json
  final List<dynamic> ingredients; // Parsed from dish_ingredients_json
  final List<dynamic> choices; // Parsed from dish_choices_json

  DishModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.dishCategoryId,
    required this.description,
    required this.optionSets,
    required this.ingredients,
    required this.choices,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    print("🛠 Parsing Dish JSON: $json");

    num? _parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    }

    List<dynamic> _parseJsonList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value;
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) return decoded;
        } catch (_) {}
      }
      return [];
    }

    try {
      final model = DishModel(
        id: _parseNum(json['dish_id'])?.toInt() ?? 0,
        name: json['dish_name']?.toString() ?? '',
        price: _parseNum(json['dish_price'])?.toDouble() ?? 0.0,
        imageUrl: json['dish_image']?.toString() ?? '',
        rating: _parseNum(json['rating'])?.toDouble() ?? 0.0,
        dishCategoryId: _parseNum(json['dish_category_id'])?.toInt() ?? -1,
        description: json['description']?.toString() ?? '',
        optionSets: _parseJsonList(json['dish_option_set_json']),
        ingredients: _parseJsonList(json['dish_ingredients_json']),
        choices: _parseJsonList(json['dish_choices_json']),
      );

      print(
        "✅ Parsed DishModel: ${model.name} (ID: ${model.id}, CatID: ${model.dishCategoryId})",
      );
      return model;
    } catch (e, stack) {
      print("❌ Error parsing Dish JSON: $e");
      print(stack);
      rethrow;
    }
  }
}

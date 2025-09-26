import 'dart:convert';

class Addon {
  final String name;
  final String description;
  final double price;
  final bool inStock;

  Addon({
    required this.name,
    this.description = "",
    this.price = 0.0,
    this.inStock = true,
  });

  /// 🔹 Safe fromJson: handles both Map and String
  factory Addon.fromJson(dynamic json) {
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

    return Addon(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      inStock: map['inStock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'inStock': inStock,
    };
  }
}

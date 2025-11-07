import 'package:pizza_boys/data/models/dish/dish_model.dart';

class GuestCartItemModel {
  final DishModel dish;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic> options;

  GuestCartItemModel({
    required this.dish,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.options = const {},
  });

  GuestCartItemModel copyWith({
    DishModel? dish,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    Map<String, dynamic>? options,
  }) {
    return GuestCartItemModel(
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish': dish.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'options': options,
    };
  }

  factory GuestCartItemModel.fromJson(Map<String, dynamic> json) {
    return GuestCartItemModel(
      dish: DishModel.fromJson(json['dish'] as Map<String, dynamic>),
      quantity: (json['quantity'] ?? 0) as int,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      options: (json['options'] != null)
          ? Map<String, dynamic>.from(json['options'] as Map)
          : <String, dynamic>{},
    );
  }

  @override
  String toString() =>
      'GuestCartItemModel(dishId: ${dish.id}, qty: $quantity, unit: $unitPrice, total: $totalPrice)';
}

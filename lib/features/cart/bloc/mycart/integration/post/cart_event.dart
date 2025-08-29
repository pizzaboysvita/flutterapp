import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends CartEvent {
  final int userId;
  final int dishId;
  final int storeId;
  final int quantity;
  final double price;
  final String optionsJson;

  const AddToCartEvent({
    required this.userId,
    required this.dishId,
    required this.storeId,
    required this.quantity,
    required this.price,
    required this.optionsJson,
  });

  @override
  List<Object?> get props => [userId, dishId, storeId, quantity, price, optionsJson];
}

import 'package:equatable/equatable.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends CartEvent {
  final String type;
  final int userId;
  final int dishId;
  final int storeId;
  final int quantity;
  final double price;
  final String optionsJson;
  final DishModel? dish;

  const AddToCartEvent({
    required this.type,
    required this.userId,
    required this.dishId,
    required this.storeId,
    required this.quantity,
    required this.price,
    required this.optionsJson,
    this.dish,
  });

  @override
  List<Object?> get props => [
        type,
        userId,
        dishId,
        storeId,
        quantity,
        price,
        optionsJson,
        dish,
      ];
}

class RemoveFromCartEvent extends CartEvent {
  final int cartId;
  final int userId;

  const RemoveFromCartEvent({required this.cartId, required this.userId});

  @override
  List<Object?> get props => [cartId, userId];
}

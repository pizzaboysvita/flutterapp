import 'package:equatable/equatable.dart';

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

  const AddToCartEvent({
    required this.type,   
    required this.userId,
    required this.dishId,
    required this.storeId,
    required this.quantity,
    required this.price,
    required this.optionsJson,
  });

  @override
  List<Object?> get props =>
      [type, userId, dishId, storeId, quantity, price, optionsJson]; 
}


class RemoveFromCartEvent extends CartEvent {
  final int cartId;
  final int userId;

  const RemoveFromCartEvent({
    required this.cartId,
    required this.userId,
  });

  @override
  List<Object?> get props => [cartId, userId];
}

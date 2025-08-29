import 'package:pizza_boys/data/models/cart/cart_item_model.dart';

abstract class CartGetState {}

class CartInitial extends CartGetState {}

class CartLoading extends CartGetState {}

class CartLoaded extends CartGetState {
  final List<CartItem> cartItems;
  CartLoaded(this.cartItems);
}

class CartError extends CartGetState {
  final String message;
  CartError(this.message);
}

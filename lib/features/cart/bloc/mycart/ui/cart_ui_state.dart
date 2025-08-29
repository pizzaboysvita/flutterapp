
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';

abstract class CartUIState {}

class CartLoading extends CartUIState {}

class CartLoaded extends CartUIState {
  final List<CartItem> items;
  CartLoaded(this.items);
}

class CartSuccess extends CartUIState {}

class CartFailure extends CartUIState {
  final String error;
  CartFailure(this.error);
}

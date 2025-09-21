// cart_get_event.dart
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';

abstract class CartGetEvent {}

class FetchCart extends CartGetEvent {
  final int userId;
  FetchCart(this.userId);
}

// NEW: Optimistic UI events
class RemoveCartItemLocally extends CartGetEvent {
  final int cartId;
  RemoveCartItemLocally(this.cartId);
}

class RestoreCartItem extends CartGetEvent {
  final CartItem item;
  RestoreCartItem(this.item);
}

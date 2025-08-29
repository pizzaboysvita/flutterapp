abstract class CartUIEvent {}

class LoadCartEvent extends CartUIEvent {}

class AddToCartEvent extends CartUIEvent {
  final int userId;
  final int dishId;
  final int storeId;
  final int quantity;
  final double price;
  final String optionsJson;

  AddToCartEvent({
    required this.userId,
    required this.dishId,
    required this.storeId,
    required this.quantity,
    required this.price,
    required this.optionsJson,
  });
}

class RemoveFromCartEvent extends CartUIEvent {
  final int cartId;
  RemoveFromCartEvent(this.cartId);
}

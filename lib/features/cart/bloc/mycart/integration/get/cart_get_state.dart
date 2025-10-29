
abstract class CartGetState {}

class CartInitial extends CartGetState {}

class CartLoading extends CartGetState {}

class CartLoaded extends CartGetState {
  final List<dynamic> cartItems;
  CartLoaded(this.cartItems);
}

class CartError extends CartGetState {
  final String message;
  CartError(this.message);
}

class CartGetEvent {}

class FetchCart extends CartGetEvent {
  final int userId;
  FetchCart(this.userId);
}

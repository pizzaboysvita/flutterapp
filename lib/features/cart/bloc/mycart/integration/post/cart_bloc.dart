import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart); // ✅ Register event handler
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final response = await cartRepository.addDishToCart(
        userId: event.userId,
        dishId: event.dishId,
        storeId: event.storeId,
        quantity: event.quantity,
        price: event.price,
        optionsJson: event.optionsJson,
      );
      emit(CartSuccess(response));
    } catch (e) {
      emit(CartFailure(e.toString()));
    }
  }

Future<void> _onRemoveFromCart(
  RemoveFromCartEvent event,
  Emitter<CartState> emit,
) async {
  try {
    final response = await cartRepository.removeFromCart(
      cartId: event.cartId,
      userId: event.userId,
    );
    emit(CartSuccess(response)); // Only emit success/failure
  } catch (e) {
    emit(CartFailure(e.toString()));
  }
}

}

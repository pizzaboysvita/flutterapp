import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final isGuest = await TokenStorage.isGuest();

    try {
      if (isGuest) {
        // ✅ Guest: Local add (no API)
        if (event.dish == null) {
          throw Exception("Dish data missing for guest cart add");
        }
        await LocalCartStorage.addToCart(event.dish!);
        emit(const CartSuccess({"message": "Added to cart (guest)"}));
      } else {
        // ✅ Logged-in: API add
        final response = await cartRepository.addDishToCart(
          userId: event.userId,
          dishId: event.dishId,
          storeId: event.storeId,
          quantity: event.quantity,
          price: event.price,
          optionsJson: event.optionsJson,
        );
        emit(CartSuccess(response));
      }
    } catch (e) {
      emit(CartFailure("Add to cart failed: $e"));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final isGuest = await TokenStorage.isGuest();

    try {
      if (isGuest) {
        // ✅ Guest: Local remove
        await LocalCartStorage.removeFromCart(event.cartId);
        emit(const CartSuccess({"message": "Removed from cart (guest)"}));
      } else {
        // ✅ Logged-in: API remove
        final response = await cartRepository.removeFromCart(
          cartId: event.cartId,
          userId: event.userId,
        );
        emit(CartSuccess(response));
      }
    } catch (e) {
      emit(CartFailure("Remove from cart failed: $e"));
    }
  }
}

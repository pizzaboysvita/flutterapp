import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/models/dish/guest_cart_item_model.dart';
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
    final storeId = await TokenStorage.getChosenStoreId();


    try {
     if (isGuest) {
  if (event.dish == null) {
    throw Exception("Dish data missing for guest cart add");
  }

  final optionsMap = jsonDecode(event.optionsJson);

  await LocalCartStorage.addGuestCartItem(
  storeId!, // 👈 First param
  GuestCartItemModel(
    dish: event.dish!,
    quantity: event.quantity,
    unitPrice: event.price,
    totalPrice: event.quantity * event.price,
    options: optionsMap,
  ),
);


  emit(const CartSuccess({"message": "Added to cart (guest)"}));
  return;
}
 else {
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
        final storeId = await TokenStorage.getChosenStoreId();

  await LocalCartStorage.removeFromCart(
    storeId!,       // ✅ String storeId
    event.cartId,   // ✅ int dishId
  );
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

// cart_get_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_state.dart';
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';

class CartGetBloc extends Bloc<CartGetEvent, CartGetState> {
  final CartRepository cartRepository;

  CartGetBloc(this.cartRepository) : super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<RemoveCartItemLocally>(_onRemoveCartItemLocally);
    on<RestoreCartItem>(_onRestoreCartItem);
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartGetState> emit) async {
    emit(CartLoading());
    try {
      final items = await cartRepository.fetchCart();
      emit(CartLoaded(items));
    } catch (e) {
      emit(CartError("Failed to fetch cart: $e"));
    }
  }

  void _onRemoveCartItemLocally(
    RemoveCartItemLocally event,
    Emitter<CartGetState> emit,
  ) {
    if (state is CartLoaded) {
      final current = (state as CartLoaded).cartItems;
      final updated = current
          .where((item) => item.cartId != event.cartId)
          .toList();
      emit(CartLoaded(updated)); // Just remove, no re-fetch
    }
  }

  void _onRestoreCartItem(RestoreCartItem event, Emitter<CartGetState> emit) {
    if (state is CartLoaded) {
      final current = (state as CartLoaded).cartItems;
      final updated = List<CartItem>.from(current)..add(event.item);
      emit(CartLoaded(updated));
    }
  }
}

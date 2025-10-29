import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'cart_get_event.dart';
import 'cart_get_state.dart';

class CartGetBloc extends Bloc<CartGetEvent, CartGetState> {
  final CartRepository cartRepository;

  CartGetBloc(this.cartRepository) : super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<RemoveCartItemLocally>(_onRemoveCartItemLocally);
    on<RestoreCartItem>(_onRestoreCartItem);
  }

  Future<void> _onFetchCart(
    FetchCart event,
    Emitter<CartGetState> emit,
  ) async {
    emit(CartLoading());
    final isGuest = await TokenStorage.isGuest();

    try {
      if (isGuest) {
        // ✅ Guest: fetch from local storage (no API)
        final List<DishModel> guestItems =
            await LocalCartStorage.getCartItems();

        // Convert DishModel → CartItem so UI stays consistent
        final cartItems = guestItems.map((dish) {
          return CartItem(
            cartId: dish.id,
            userId: 0,
            dishId: dish.id,
            storeId: dish.storeId,
            quantity: 1,
            price: dish.price,
            status: "guest",
            createdOn: DateTime.now(),
            updatedOn: DateTime.now(),
            options: {},
            imageUrl: dish.imageUrl,
            dishName: dish.name,
            dishImage: dish.imageUrl,
          );
        }).toList();

        emit(CartLoaded(cartItems));
      } else {
        // ✅ Logged-in: API flow
        final items = await cartRepository.fetchCart();
        emit(CartLoaded(items));
      }
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
      final updated =
          current.where((item) => item.cartId != event.cartId).toList();
      emit(CartLoaded(updated));
    }
  }

  void _onRestoreCartItem(
    RestoreCartItem event,
    Emitter<CartGetState> emit,
  ) {
    if (state is CartLoaded) {
      final current = (state as CartLoaded).cartItems;
      final updated = List<CartItem>.from(current)..add(event.item);
      emit(CartLoaded(updated));
    }
  }
}

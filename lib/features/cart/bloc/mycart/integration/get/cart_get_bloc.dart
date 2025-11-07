import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/models/dish/guest_cart_item_model.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'cart_get_event.dart';
import 'cart_get_state.dart';

class CartGetBloc extends Bloc<CartGetEvent, CartGetState> {
  final CartRepository cartRepository;

  CartGetBloc(this.cartRepository) : super(CartInitial()) {
    print("🟩 CartGetBloc created");
    on<FetchCart>(_onFetchCart);
    on<RemoveCartItemLocally>(_onRemoveCartItemLocally);
    on<RestoreCartItem>(_onRestoreCartItem);
    on<ClearCartEvent>((event, emit) {
  emit(CartLoaded([]));
});

  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartGetState> emit) async {
    emit(CartLoading());
    final isGuest = await TokenStorage.isGuest();
    final storeId = await TokenStorage.getChosenStoreId();

    try {
     if (isGuest) {
  final List<GuestCartItemModel> guestItems =
      await LocalCartStorage.getGuestCartItems(storeId!);

  final cartItems = guestItems.map((item) {
    return CartItem(
      cartId: item.dish.id,
      userId: 0,
      dishId: item.dish.id,
      storeId: item.dish.storeId ?? 0,
      quantity: item.quantity,
      price: item.unitPrice,
      status: "guest",
      createdOn: DateTime.now(),
      updatedOn: DateTime.now(),
      options: item.options,
      imageUrl: item.dish.imageUrl,
      dishName: item.dish.name,
      dishImage: item.dish.imageUrl,
    );
  }).toList();

  emit(CartLoaded(cartItems));
  return;
}
else {
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
      final updated = current
          .where((item) => item.cartId != event.cartId)
          .toList();
      emit(CartLoaded(updated));
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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/ui/cart_ui_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/ui/cart_ui_state.dart';

class CartUIBloc extends Bloc<CartUIEvent, CartUIState> {
  final List<CartItem> _cartItems = [];

  CartUIBloc() : super(CartLoading()) {
    on<LoadCartEvent>((event, emit) {
      emit(CartLoaded(List.from(_cartItems)));
    });

    on<AddToCartEvent>((event, emit) {
      try {
        final newItem = CartItem(
          cartId: DateTime.now().millisecondsSinceEpoch, // temp unique id
          userId: event.userId,
          dishId: event.dishId,
          storeId: event.storeId,
          quantity: event.quantity,
          price: event.price,
          status: "active",
          createdOn: DateTime.now(),
          updatedOn: DateTime.now(),
          options: {"json": event.optionsJson},
        );

        _cartItems.add(newItem);
        emit(CartLoaded(List.from(_cartItems)));
        emit(CartSuccess()); // success state for snackbars, navigation, etc.
      } catch (e) {
        emit(CartFailure(e.toString()));
      }
    });

    on<RemoveFromCartEvent>((event, emit) {
      _cartItems.removeWhere((item) => item.cartId == event.cartId);
      emit(CartLoaded(List.from(_cartItems)));
    });
  }
}

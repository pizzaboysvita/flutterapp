import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/cart/cart_repo.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_state.dart';


class CartGetBloc extends Bloc<CartGetEvent, CartGetState> {
  final CartRepository cartRepository;

  CartGetBloc(this.cartRepository) : super(CartInitial()) {
    on<FetchCart>((event, emit) async {
      emit(CartLoading());
      try {
        final items = await cartRepository.fetchCart();
        emit(CartLoaded(items));
      } catch (e) {
        emit(CartError("Failed to fetch cart: $e"));
      }
    });
  }
}

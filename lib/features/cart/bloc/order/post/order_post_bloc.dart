// order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/order/order_repo.dart';
import 'package:pizza_boys/features/cart/bloc/order/post/order_post_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/post/order_post_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;

  OrderBloc({required this.repository}) : super(OrderInitial()) {
    on<PlaceOrderEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        final success = await repository.placeOrder(event.order);

        if (success) {
          emit(
            OrderSuccess(
              message: "Order placed successfully",
              order: event.order,
            ),
          );
        } else {
          emit(OrderFailure("Failed to place order"));
        }
      } catch (e) {
        emit(OrderFailure(e.toString()));
      }
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/order/order_repo.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_state.dart';

class OrderGetBloc extends Bloc<OrderGetEvent, OrderGetState> {
  final OrderRepository repository;

  OrderGetBloc(this.repository) : super(OrderInitial()) {
    on<LoadOrdersEvent>((event, emit) async {
      emit(OrderLoading());
      try {
        final orders = await repository
            .fetchOrders(); // should return List<OrderGetModel>

        emit(OrderLoaded(orders));
      } catch (e, stackTrace) {
        emit(OrderError(e.toString()));
      }
    });
  }
}

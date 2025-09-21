import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/order/order_repo.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_state.dart';

class OrderGetBloc extends Bloc<OrderGetEvent, OrderGetState> {
  final OrderRepository repository;

  OrderGetBloc(this.repository) : super(OrderInitial()) {
    on<LoadOrdersEvent>((event, emit) async {
      print("🟠 LoadOrdersEvent triggered");
      emit(OrderLoading());
      try {
        final orders = await repository.fetchOrders(); // should return List<OrderGetModel>
        print("✅ Orders fetched successfully: ${orders.length} orders");
        emit(OrderLoaded(orders));
      } catch (e, stackTrace) {
        print("❌ Error fetching orders: $e");
        print(stackTrace);
        emit(OrderError(e.toString()));
      }
    });
  }
}

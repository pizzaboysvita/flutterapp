import 'package:pizza_boys/data/models/order/order_get_model.dart';

abstract class OrderGetState {}

class OrderInitial extends OrderGetState {}

class OrderLoading extends OrderGetState {}

class OrderLoaded extends OrderGetState {
  final List<OrderGetModel> orders; // ✅ Use OrderGetModel here

  OrderLoaded(this.orders);
}

class OrderError extends OrderGetState {
  final String message;

  OrderError(this.message);
}

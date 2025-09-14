import 'package:pizza_boys/data/models/order/order_post_model.dart'; // ✅ import your model

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final String message;
  final OrderModel order; // ✅ Add this field

  OrderSuccess({
    required this.message,
    required this.order,
  }); // ✅ Update constructor
}

class OrderFailure extends OrderState {
  final String message;
  OrderFailure(this.message);
}

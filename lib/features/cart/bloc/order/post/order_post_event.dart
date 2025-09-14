// order_event.dart

import 'package:pizza_boys/data/models/order/order_post_model.dart';

abstract class OrderEvent {}

class PlaceOrderEvent extends OrderEvent {
  final OrderModel order;
  PlaceOrderEvent(this.order);
}

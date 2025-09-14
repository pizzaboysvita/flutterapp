import 'package:pizza_boys/data/models/order/order_post_model.dart';
import 'package:pizza_boys/data/services/order/order_service.dart';

class OrderRepository {
  final OrderService service;
  OrderRepository(this.service);

  Future<bool> placeOrder(OrderModel order) async {
    return await service.placeOrder(order);
  }

  Future<List<OrderModel>> fetchOrders() async {
    return await service.fetchOrders();
  }
}

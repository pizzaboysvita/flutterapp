import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/order/order_get_model.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';

class OrderService {
  // Post API
  Future<bool> placeOrder(OrderModel order) async {
    // 🔹 Get token from storage
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      throw Exception("No access token found. User might not be logged in.");
    }

    final response = await http.post(
      Uri.parse(ApiUrls.postOrders),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // 🔹 Add Bearer token
      },
      body: jsonEncode(order.toJson()),
    );

    print("📤 Request body: ${order.toJson()}");
    print("📥 Response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["code"] == "1";
    } else {
      throw Exception("Failed to place order: ${response.body}");
    }
  }

  // Get Api
  final String baseUrl = 'http://78.142.47.247:3003/api/order';

  Future<List<OrderModel>> fetchOrders() async {
    final token = await TokenStorage.getAccessToken();
    final userId = await TokenStorage.getUserId();
    print('UserId from Storage: $userId');
    final uri = Uri.parse(
      '$baseUrl?store_id=-1&type=web&user_id=${userId.toString()}',
    );

    print("📡 Making request to $uri");
    print("🔑 Token: $token");

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📥 Response code: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("📂 Parsed data: $data");

      if (data['code'] == '1') {
        final orders = (data['categories'] as List)
            .map((json) {
              print("➡ Parsing order: $json");
              return OrderGetModel.fromJson(json);
            })
            .map((orderGetModel) {
              print("➡ Converting OrderGetModel to OrderModel");
              return OrderModel(
                totalPrice: double.tryParse(orderGetModel.totalPrice) ?? 0.0,
                totalQuantity: orderGetModel.totalQuantity,
                storeId: orderGetModel.storeId,
                orderType: orderGetModel.orderType.toString(),
                pickupDatetime: orderGetModel.pickupDatetime,
                deliveryAddress: orderGetModel.deliveryAddress,
                deliveryFees:
                    double.tryParse(orderGetModel.deliveryFees) ?? 0.0,
                deliveryDatetime: orderGetModel.deliveryDatetime,
                orderNotes: orderGetModel.orderNotes ?? "",
                orderStatus: orderGetModel.orderStatus,
                orderCreatedBy: 0,
                toppingDetails: [],
                ingredientDetails: [],
                orderDetails: [],
                paymentMethod: "Cash",
                paymentStatus: "Pending",
                paymentAmount: 0.0,
                isPosOrder: orderGetModel.isPosOrder,
                unitNumber: orderGetModel.unitNumber ?? "",
                gstPrice: double.tryParse(orderGetModel.gstPrice ?? '0') ?? 0.0,

              );
            })
            .toList();

        print("✅ Total orders parsed: ${orders.length}");
        return orders;
      } else {
        print("❌ API error: ${data['message']}");
        throw Exception(data['message']);
      }
    } else {
      print("❌ HTTP error: ${response.statusCode}");
      throw Exception('Failed to load orders');
    }
  }
}

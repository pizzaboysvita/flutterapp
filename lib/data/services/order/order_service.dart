import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/order/order_get_model.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';

class OrderService {
  // Post API: Place Order
  Future<bool> placeOrder(OrderModel order) async {
    try {
      final orderJson = order.toJson();

      print("📤 Sending Order to Backend...");
      print("🔗 Endpoint: ${ApiUrls.postOrders}");
      print("🧾 Payload: $orderJson");

      final response = await ApiClient.dio.post(
        ApiUrls.postOrders,
        data: orderJson,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("✅ Response Status: ${response.statusCode}");
      print("✅ Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["code"].toString() == "1";
      } else {
        print("⚠️ Unexpected response: ${response.data}");
        throw Exception("Failed to place order: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ DioException caught!");
      print("Type: ${e.type}");
      print("Message: ${e.message}");

      if (e.response != null) {
        print("❌ Backend Response Status: ${e.response?.statusCode}");
        print("❌ Backend Response Body: ${e.response?.data}");
      }

      throw Exception(
        "Failed to place order: ${e.message} | Backend: ${e.response?.data}",
      );
    } catch (e) {
      print("🔥 Unexpected error: $e");
      throw Exception("Failed to place order: $e");
    }
  }

  // Get API: Fetch Orders
  Future<List<OrderGetModel>> fetchOrders() async {
    try {
      final userId = await TokenStorage.getUserId();
      final storeId = await TokenStorage.getChosenStoreId();
      final sid = int.tryParse(storeId ?? "");

      print("🔍 FETCH ORDERS FOR userId=$userId storeId=$sid");

      final getOrders = 'order?user_id=$userId&store_id=$storeId&type=web';

      final response = await ApiClient.dio.get(
        getOrders,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("📡 STATUS CODE: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        print("📦 RAW RESPONSE: $data");
        print("🔍 API 'code': ${data['code']}");
        print("🔍 API 'message': ${data['message']}");

        // Convert ALL orders
        final rawOrders = (data['categories'] as List)
            .map((json) => OrderGetModel.fromJson(json))
            .toList();

        print("📦 RAW ORDERS COUNT: ${rawOrders.length}");

        // 🔥 FILTER HERE
        final filteredOrders = rawOrders
            .where((o) => o.storeId == sid)
            .toList();

        print(
          "🎯 FILTERED ORDERS COUNT (storeId=$sid): ${filteredOrders.length}",
        );

        return filteredOrders;
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch orders: ${e.message}');
    }
  }
}

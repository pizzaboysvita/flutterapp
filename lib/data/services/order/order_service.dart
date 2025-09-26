import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/order/order_get_model.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';

class OrderService {
  // Post API: Place Order
  Future<bool> placeOrder(OrderModel order) async {
    print('hiited order post api');
    try {
      final orderJson = order.toJson();
      print("📤 Sending order JSON: $orderJson");
      print("📤 Sending order JSON keys: ${orderJson.keys}");
      print("📤 Sending order JSON: ${jsonEncode(orderJson)}");

      final response = await ApiClient.dio.post(
        ApiUrls.postOrders,
        data: orderJson,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("📥 Response: ${response.statusCode} ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["code"].toString() == "1";
      } else {
        // Log backend error
        print("❌ Backend returned error: ${response.data}");
        throw Exception("Failed to place order: ${response.data}");
      }
    } on DioException catch (e) {
      // Print Dio exception type and message
      print("⚠️ DioException: ${e.type} → ${e.message}");

      // If backend responded with 4xx/5xx, print the response
      if (e.response != null) {
        print(
          "❌ Backend response: ${e.response?.statusCode} ${e.response?.data}",
        );
      }

      // Rethrow to propagate the error
      throw Exception(
        "Failed to place order: ${e.message} | Backend: ${e.response?.data}",
      );
    } catch (e) {
      print("❌ Unknown error: $e");
      throw Exception("Failed to place order: $e");
    }
  }

  // Get API: Fetch Orders

  Future<List<OrderGetModel>> fetchOrders() async {
    try {
      final userId = await TokenStorage.getUserId();
      final storeId = await TokenStorage.getChosenStoreId();

      final getOrders =
          'order?user_id=${userId ?? 1}&store_id=${storeId ?? 48}&type=web';

      print("Fetching orders from: $getOrders");

      final response = await ApiClient.dio.get(
        getOrders,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == '1') {
          final orders = (data['categories'] as List)
              .map((json) => OrderGetModel.fromJson(json))
              .toList();
          return orders;
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("❌ Error fetching orders: ${e.message}");
      throw Exception('Failed to fetch orders: ${e.message}');
    }
  }
}

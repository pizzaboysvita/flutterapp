import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class PromoRepository {
  Future<List<Map<String, dynamic>>> fetchPromos(int storeId) async {
    print("\n🟦============================");
    print("🟦 [PromoRepository] fetchPromos() CALLED");
    print("🟦 Store ID: $storeId");
    print("============================\n");

    try {
      // 🔑 Fetch stored access token
      final token = await TokenStorage.getAccessToken();
      print("🔑 [PromoRepository] Current Access Token: $token");

      // ✅ Prepare request URL
      final String url = "${ApiClient.dio.options.baseUrl}promocode";
      print("🌐 [PromoRepository] Request URL: $url");
      print("📦 [PromoRepository] Query Params: {store_id: $storeId}");

      // ✅ Make GET request
      final response = await ApiClient.dio.get(
        "promocode",
        queryParameters: {"store_id": storeId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      // 🧾 Log response
      print("\n📡 [PromoRepository] API RESPONSE:");
      print("➡️ Status Code: ${response.statusCode}");
      print("➡️ Response Body: ${response.data}");

      // ✅ Success case
      if (response.statusCode == 200 && response.data["code"] == 1) {
        final List data = response.data["data"];
        print(
          "✅ [PromoRepository] Promo fetch successful | Count: ${data.length}",
        );
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        print(
          "⚠️ [PromoRepository] API returned failure | Code: ${response.data["code"]}",
        );
        throw Exception("Failed to load promo codes");
      }
    } on DioException catch (e) {
      print("\n🚨 [PromoRepository] DioException caught!");
      print("➡️ Error Type: ${e.type}");
      print("➡️ Message: ${e.message}");
      print("➡️ Status Code: ${e.response?.statusCode}");
      print("➡️ Response Data: ${e.response?.data}");
      print("➡️ Request Options: ${e.requestOptions.uri}");
      print("➡️ Headers Sent: ${e.requestOptions.headers}");

      // Detect expired token or refresh fail
      if (e.response?.statusCode == 401) {
        print(
          "🔁 [PromoRepository] Got 401 Unauthorized — Token may have expired or refresh failed",
        );
      }

      rethrow;
    } catch (e, s) {
      print("\n❌ [PromoRepository] Unknown Exception: $e");
      print("🧩 Stacktrace: $s");
      rethrow;
    }
  }
}

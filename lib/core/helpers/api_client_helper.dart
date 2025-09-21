import 'package:dio/dio.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class ApiClient {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: "http://78.142.47.247:3003/api/",
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStorage.getAccessToken();
              print("🔹 [ApiClient] Attaching access token: $token");
              if (token != null) {
                options.headers["Authorization"] = "Bearer $token";
              }
              return handler.next(options);
            },
            onError: (e, handler) async {
              print(
                "⚠️ [ApiClient] Request failed with status: ${e.response?.statusCode}",
              );
              print("⚠️ [ApiClient] Error data: ${e.response?.data}");

              // Only handle 401
              if (e.response?.statusCode == 401) {
                print("🔄 [ApiClient] Access token expired, trying refresh...");
                final refreshed = await _refreshAccessToken();

                if (refreshed) {
                  final newToken = await TokenStorage.getAccessToken();
                  print(
                    "🔹 [ApiClient] Retrying request with new token: $newToken",
                  );

                  e.requestOptions.headers["Authorization"] =
                      "Bearer $newToken";

                  try {
                    final retryResponse = await dio.fetch(e.requestOptions);
                    print(
                      "✅ [ApiClient] Retry successful with status: ${retryResponse.statusCode}",
                    );
                    return handler.resolve(retryResponse);
                  } catch (err) {
                    print("❌ [ApiClient] Retry after refresh failed: $err");
                    return handler.next(e);
                  }
                } else {
                  print(
                    "🚪 [ApiClient] Refresh token invalid or expired, clearing session...",
                  );
                  await TokenStorage.clearSession();
                }
              }

              return handler.next(e);
            },
          ),
        );

  // Refresh token logic
  static Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      print("🔍 [ApiClient] Refresh token fetched: $refreshToken");

      if (refreshToken == null) {
        print("⚠️ [ApiClient] No refresh token found!");
        return false;
      }

      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));

      print("📤 [ApiClient] Sending refresh token request...");
      final response = await refreshDio.post(
        "refreshToken",
        data: {"refresh_token": refreshToken},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("📥 [ApiClient] Refresh token response: ${response.data}");

      if (response.data["code"] == 1) {
        print("🔄 [ApiClient] Saving new access + refresh tokens...");
        await TokenStorage.saveSession({
          "access_token": response.data["access_token"],
          "refresh_token": response.data["refresh_token"],
          "user": null,
        });

        print("✅ [ApiClient] Access token refreshed successfully");
        return true;
      } else {
        print(
          "❌ [ApiClient] Refresh token rejected by server: ${response.data}",
        );
        return false;
      }
    } catch (e, s) {
      print("⚠️ [ApiClient] Refresh token error: $e");
      print("📜 Stack trace: $s");
      return false;
    }
  }
}

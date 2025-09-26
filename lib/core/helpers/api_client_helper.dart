import 'package:dio/dio.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/helpers/internet_helper/server_error_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://78.142.47.247:3003/api/",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 50),
    ),
  )..interceptors.add(
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
          print("⚠️ [ApiClient] Request failed! ${e.type} → ${e.message}");

          // -------------------------------
          // 1️⃣ Handle timeout
          // -------------------------------
          if (e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionTimeout) {
            print("⏳ [ApiClient] Timeout detected, retrying once...");

            try {
              // retry once
              final retryResponse = await dio.fetch(e.requestOptions);
              print("✅ [ApiClient] Retry after timeout succeeded!");
              return handler.resolve(retryResponse);
            } catch (retryError) {
              print("❌ [ApiClient] Retry after timeout failed: $retryError");

              // Show server timeout screen (replace with GetX nav if using Get)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(e.requestOptions.extra["context"], rootNavigator: true).push(
  MaterialPageRoute(
    builder: (_) => ServerTimeoutScreen(
      bloc: ServerTimeoutBloc(
        dio: dio, // use the static dio
        requestOptions: e.requestOptions, // from the exception
      ),
    ),
  ),
);


              });

              return handler.next(e);
            }
          }

          // -------------------------------
          // 2️⃣ Handle token refresh
          // -------------------------------
          if (e.response?.statusCode == 401) {
            print("🔄 [ApiClient] Access token expired, trying refresh...");
            final refreshed = await _refreshAccessToken();

            if (refreshed) {
              final newToken = await TokenStorage.getAccessToken();
              e.requestOptions.headers["Authorization"] = "Bearer $newToken";

              try {
                final retryResponse = await dio.fetch(e.requestOptions);
                print("✅ [ApiClient] Retry successful with new token");
                return handler.resolve(retryResponse);
              } catch (err) {
                print("❌ [ApiClient] Retry after refresh failed: $err");
                return handler.next(e);
              }
            } else {
              print("🚪 [ApiClient] Refresh failed, clearing session...");
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
      if (refreshToken == null) return false;

      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final response = await refreshDio.post(
        "refreshToken",
        data: {"refresh_token": refreshToken},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.data["code"] == 1) {
        await TokenStorage.saveSession({
          "access_token": response.data["access_token"],
          "refresh_token": response.data["refresh_token"],
          "user": null,
        });
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}

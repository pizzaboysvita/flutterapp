// api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/session/session_manager.dart';
import 'package:pizza_boys/core/session/token_manager.dart';

class ApiClient {
  static bool isShowingServerError = false;

  /// Checks device connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// ✅ Helper: check if token will expire soon (within X seconds)
  static bool isTokenExpiringSoon(String token, {int thresholdSeconds = 60}) {
    try {
      final expiry = JwtDecoder.getExpirationDate(token);
      final secondsLeft = expiry.difference(DateTime.now()).inSeconds;
      print("⏳ [ApiClient] Token expires in $secondsLeft seconds");
      return secondsLeft < thresholdSeconds;
    } catch (e) {
      print("⚠️ [ApiClient] Failed to decode JWT for expiry check: $e");
      return false;
    }
  }

  /// ✅ Helper: check if token is already expired
  static bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print("⚠️ [ApiClient] Failed to decode JWT for expiration check: $e");
      return true;
    }
  }

    static int getTokenExpiryInSeconds(String token) {
    try {
      final expiryDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final diff = expiryDate.difference(now).inSeconds;
      return diff > 0 ? diff : 0;
    } catch (e) {
      print("⚠️ [ApiClient] Failed to decode JWT for expiry seconds: $e");
      return 0;
    }
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://78.142.47.247:3004/api/",
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
      validateStatus: (status) => true,
    ),
  )..interceptors.add(
  InterceptorsWrapper(
 onRequest: (options, handler) async {
  final excludedEndpoints = [
    ApiUrls.loginPost,
  ];

  if (excludedEndpoints.any((url) => options.path.contains(url))) {
    return handler.next(options); 
  }

  final token = await TokenManager.getValidAccessToken();

  if (token != null && token.isNotEmpty) {
    options.headers["Authorization"] = "Bearer $token";
  }

  return handler.next(options);
},


    onError: (DioError err, handler) async {
      if (err.response?.statusCode == 401) {
        print("🔐 [ApiClient] 401 — attempting refresh once");

        final newToken = await TokenManager.getValidAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers["Authorization"] = "Bearer $newToken";
          final retry = await dio.fetch(err.requestOptions);
          return handler.resolve(retry);
        } else {
          print("⛔ [ApiClient] Refresh failed, logging out user");
          if (NavigatorService.context != null) {
            await SessionManager.clearSession(NavigatorService.context!);
          }
          return handler.next(err);
        }
      }

      return handler.next(err);
    },
  ),
);
}

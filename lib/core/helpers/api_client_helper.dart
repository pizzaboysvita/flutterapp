// ignore_for_file: empty_catches

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_notifier.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/helpers/internet_helper/global_error_handler.dart';
import 'package:pizza_boys/core/session/session_manager.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      GlobalErrorHandler.handleError("Invalid token format");
      return true;
    }

    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload['exp'];
    if (exp == null) {
      GlobalErrorHandler.handleError("No 'exp' claim in token");
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isExpired = exp < now;

    print("🕒 [TokenCheck] Exp: $exp | Now: $now | Expired: $isExpired");
    return isExpired;
  } catch (e, s) {
    GlobalErrorHandler.handleError("Error decoding token: $e", stackTrace: s);
    return true;
  }
}

class ApiClient {
  static bool isShowingServerError = false; // Prevent multiple screens

  /// Checks internet connectivity without relying on any Bloc or context
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://78.142.47.247:3003/api/",
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
      validateStatus: (status) => true,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await TokenStorage.getAccessToken();
            if (token != null) {
              options.headers["Authorization"] = "Bearer $token";
            }
          } catch (e, s) {
            GlobalErrorHandler.handleError(e, stackTrace: s);
          }
          return handler.next(options);
        },

        onResponse: (response, handler) async {
          try {
            if (response.statusCode == 500) {
              GlobalErrorHandler.handleError(
                "500 Internal Server Error detected!",
              );
if (ApiClient.isShowingServerError) return;
ApiClient.isShowingServerError = true;

              await ErrorNotifier.showErrorScreen(
                response.requestOptions,
                "Internal Server Error. Please try again later.",
                ErrorScreenType.server,
                true,
              );
            }
          } catch (e, s) {
            GlobalErrorHandler.handleError(e, stackTrace: s);
          }
          return handler.next(response);
        },

       onError: (DioError err, ErrorInterceptorHandler handler) async {
  try {
    final requestOptions = err.requestOptions;

    // Only retry for 500 server errors
    if (err.response?.statusCode == 500) {
      if (ApiClient.isShowingServerError) return;
      ApiClient.isShowingServerError = true;

      // Show error screen
      await ErrorNotifier.showErrorScreen(
        requestOptions, // pass the original request options
        "Server temporarily unavailable. Please try again.",
        ErrorScreenType.server,
        true,
      );

      // Stop further handling
      return;
    }

    // Handle token expired if needed
    if (err.response?.statusCode == 401 && isTokenExpired(await TokenStorage.getAccessToken() ?? "")) {
      await TokenRefreshLock.run(() async {
        final retryResponse = await ApiClient.dio.fetch(requestOptions);
        handler.resolve(retryResponse); // resolves retry automatically
      });
      return;
    }
  } catch (e, s) {
    GlobalErrorHandler.handleError(e, stackTrace: s);
  }

  return handler.next(err);
}
      
      ),
    );

  /// Refresh access token safely, with global error logging
  static Future<bool> _refreshAccessToken({int maxRetries = 1}) async {
    int attempt = 0;
    while (attempt <= maxRetries) {
      attempt++;
      try {
        final refreshToken = await TokenStorage.getRefreshToken();
        if (refreshToken == null) return false;

        final response = await dio.post(
          "refreshToken",
          data: {"refresh_token": refreshToken},
        );

        if (response.statusCode == 200 && response.data["code"] == 1) {
          await TokenStorage.saveSession({
            "access_token": response.data["access_token"],
            "refresh_token": response.data["refresh_token"],
            "user": null,
          });
          return true;
        } else {
          GlobalErrorHandler.handleError(
            "Refresh failed: ${response.data["message"]}",
          );
        }
      } catch (e, s) {
        GlobalErrorHandler.handleError(
          "Refresh attempt $attempt failed: $e",
          stackTrace: s,
        );
      }

      if (attempt <= maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return false;
  }
}

class TokenRefreshLock {
  static bool _isRefreshing = false;
  static final List<Future<void> Function()> _queue = [];

  static Future<void> run(Future<void> Function() retry) async {
    if (_isRefreshing) {
      _queue.add(retry);
      return;
    }

    _isRefreshing = true;

    bool success = await ApiClient._refreshAccessToken();
    _isRefreshing = false;

    for (var queuedRetry in _queue) {
      await queuedRetry();
    }
    _queue.clear();

    if (!success && NavigatorService.context != null) {
      SessionManager.clearSession(NavigatorService.context!);
    }
  }
}

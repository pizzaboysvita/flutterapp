import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';
import 'package:pizza_boys/core/helpers/internet_helper/network_issue_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/server_error_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class ApiClient {
  static BuildContext? _rootContext;
  static bool isShowingServerError = false; // ✅ Prevent multiple screens
  static BuildContext? get rootContext => _rootContext;
  static void init(BuildContext context) {
    _rootContext = context;
  }

  static Future<bool> _hasInternetConnection() async {
    try {
      bool stateHasInternet = BlocProvider.of<ConnectivityBloc>(
        _rootContext!,
      ).state.hasInternet;
      if (stateHasInternet) {
        // Optionally check actual connectivity
        final result = await InternetAddress.lookup('example.com');
        return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: "http://78.142.47.247:3003/api/",
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 50),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStorage.getAccessToken();
              print(
                "🔹 [ApiClient] Request → ${options.method} ${options.uri}",
              );
              print("📦 Request Data: ${options.data}");
              if (token != null) {
                options.headers["Authorization"] = "Bearer $token";
                print("🔑 Added Token: $token");
              }
              return handler.next(options);
            },
            onResponse: (response, handler) {
              print("✅ [ApiClient] Success → ${response.statusCode}");
              print("📥 Response Data: ${response.data}");
              return handler.next(response);
            },
            onError: (e, handler) async {
              print("⚠️ [ApiClient] Request failed → ${e.type}");
              print("🛑 Message: ${e.message}");

              // Print failing API details
              print("🔗 API URL: ${e.requestOptions.uri}");
              print("📌 Method: ${e.requestOptions.method}");
              print("📦 Request Data: ${e.requestOptions.data}");
              print("🗂 Headers: ${e.requestOptions.headers}");

              bool hasInternet = await _hasInternetConnection();
              print("📡 Internet status: $hasInternet");

              // Handle error based on connectivity and error type
              await _handleError(e.requestOptions, e, hasInternet);

              // Handle token refresh separately
              if (hasInternet && e.response?.statusCode == 401) {
                print("🔄 [ApiClient] Access token expired, trying refresh...");
                final refreshed = await _refreshAccessToken();
                if (refreshed) {
                  final newToken = await TokenStorage.getAccessToken();
                  e.requestOptions.headers["Authorization"] =
                      "Bearer $newToken";
                  try {
                    final retryResponse = await dio.fetch(e.requestOptions);
                    return handler.resolve(retryResponse);
                  } catch (err) {
                    print("❌ [ApiClient] Retry after refresh failed: $err");
                    return handler.next(e);
                  }
                } else {
                  await TokenStorage.clearSession();
                }
              }

              // Also log server error details if available
              if (e.response != null) {
                print("🖥 Server Response Status: ${e.response?.statusCode}");
                print("🗒 Server Response Data: ${e.response?.data}");
              }

              return handler.next(e);
            },
          ),
        );

  static Future<void> _handleError(
    RequestOptions options,
    DioException e,
    bool hasInternet,
  ) async {
    if (!hasInternet) {
      await _showErrorScreen(
        options,
        "No internet connection",
        ErrorScreenType.network,
        hasInternet,
      );
    } else if (e.type == DioExceptionType.connectionError &&
        e.response == null) {
      await _showErrorScreen(
        options,
        "Server not reachable. Please try later.",
        ErrorScreenType.server,
        hasInternet,
      );
    } else if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      await _showErrorScreen(
        options,
        "It’s taking too long to connect. Please retry.",
        ErrorScreenType.server,
        hasInternet,
      );
    }
  }

  static Future<void> _showErrorScreen(
    RequestOptions options,
    String message,
    ErrorScreenType type,
    bool hasInternet, // ✅ Avoid re-check
  ) async {
    if (_rootContext == null) return;

    if (ErrorScreenTracker.isShowing) {
      print("⚠️ Error screen already showing — skipping...");
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasInternet) {
        if (ErrorScreenTracker.canShow(ErrorScreenType.network)) {
          ErrorScreenTracker.set(ErrorScreenType.network);
          Navigator.of(_rootContext!, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NetworkIssueScreen(
                onRetry: () {
                  ErrorScreenTracker.reset();
                  Navigator.pop(_rootContext!);
                  BlocProvider.of<ConnectivityBloc>(
                    _rootContext!,
                  ).recheckConnection();
                },
              ),
            ),
            (route) => false,
          );
        }
      } else {
        if (ErrorScreenTracker.canShow(type)) {
          ErrorScreenTracker.set(type);
          Navigator.of(_rootContext!, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ServerTimeoutScreen(
                bloc: ServerTimeoutBloc(dio: dio, requestOptions: options),
                errorMessage: message,
                onClose: () {
                  isShowingServerError = false;
                  ErrorScreenTracker.reset();
                },
              ),
            ),
            (route) => false,
          );
        }
      }
    });
  }

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

      print("🔄 [ApiClient] Refresh Token Response → ${response.data}");

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
    } catch (err) {
      print("❌ [ApiClient] Refresh Token Error: $err");
      return false;
    }
  }
}

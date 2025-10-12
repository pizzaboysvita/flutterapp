import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';
import 'package:pizza_boys/core/helpers/internet_helper/network_issue_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/server_error_helper.dart';
import 'package:pizza_boys/core/session/session_manager.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

import 'dart:convert';

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload['exp'];
    if (exp == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp < now;
  } catch (e) {
    return true;
  }
}

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

  static void _showTimeoutSnackbar(String message) {
    if (_rootContext != null) {
      ScaffoldMessenger.of(_rootContext!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: "http://78.142.47.247:3003/api/",
            connectTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
            // 👇 VERY IMPORTANT: Allow all status codes to pass through
            validateStatus: (status) => true,
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              String? token = await TokenStorage.getAccessToken();

              if (token != null) {
                bool expired = isTokenExpired(token);

                if (expired) {
                  bool refreshed = await ApiClient._refreshAccessToken();

                  if (refreshed) {
                    token = await TokenStorage.getAccessToken();
                  } else {
                    print(
                      "❌ [ApiClient] Token refresh failed — clearing session",
                    );
                    SessionManager.clearSession(ApiClient.rootContext!);
                    return;
                  }
                }
              } else {}

              if (token != null) {
                options.headers["Authorization"] = "Bearer $token";
                print(
                  "🔹 [ApiClient] Request Headers AFTER: ${options.headers}",
                );
              } else {}

              return handler.next(options);
            },
            onResponse: (response, handler) {
              return handler.next(response);
            },
            onError: (e, handler) async {
              bool hasInternet = await _hasInternetConnection();

              // Handle server responses with messages
              if (e.response?.data is Map &&
                  e.response?.data["message"] != null) {
                return handler.resolve(
                  Response(
                    requestOptions: e.requestOptions,
                    statusCode: e.response?.statusCode,
                    data: {
                      "code": e.response?.data["code"] ?? 0,
                      "message": e.response?.data["message"],
                    },
                  ),
                );
              }

              // Handle connection timeout or receive timeout
              if (e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout) {
                _showTimeoutSnackbar(
                  "It’s taking longer than usual. Please try again.",
                );
                return handler.reject(e); // Let it stop the request chain
              }

              // Handle other connectivity/server errors
              await _handleError(e.requestOptions, e, hasInternet);

              // Token expired case
              if (hasInternet && e.response?.statusCode == 401) {
                Future<void> retry() async {
                  final newToken = await TokenStorage.getAccessToken();
                  if (newToken != null) {
                    e.requestOptions.headers["Authorization"] =
                        "Bearer $newToken";
                    try {
                      final retryResponse = await dio.fetch(e.requestOptions);
                      handler.resolve(retryResponse);
                      return;
                    } catch (err) {}
                  }
                  handler.next(e);
                }

                await TokenRefreshLock.run(retry);
                return;
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

      if (refreshToken == null) {
        return false;
      }

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
    } catch (err) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        return await _refreshAccessToken();
      } catch (_) {
        return false;
      }
    }
  }
}

class TokenRefreshLock {
  static bool _isRefreshing = false;
  static final List<Future<void> Function()> _queue = [];

  static Future<void> run(Future<void> Function() retry) async {
    if (_isRefreshing) {
      _queue.add(retry); // ✅ now type matches
      return;
    }

    _isRefreshing = true;

    bool success = await ApiClient._refreshAccessToken();
    _isRefreshing = false;

    for (var queuedRetry in _queue) {
      await queuedRetry(); // ✅ await async retry
    }
    _queue.clear();

    if (!success && ApiClient.rootContext != null) {
      SessionManager.clearSession(ApiClient.rootContext!);
    }
  }
}

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/session/session_manager.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class TokenManager {

  
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://78.142.47.247:3003/api/"),
  );
  static bool _isRefreshing = false;
  static final List<Function(String)> _queue = [];

  /// ✅ Get a valid access token
/// ✅ Get a valid access token
static Future<String?> getValidAccessToken() async {
  // ✅ 1. Check if guest session FIRST — return guest token and SKIP JWT checks
  final isGuest = await TokenStorage.isGuest();
  if (isGuest) {
    print("🧭 Guest session active — returning guest token (no refresh logic).");
    return "guest_session_token"; // your actual guest token placeholder
  }

  // ✅ 2. Normal user token flow
  final token = await TokenStorage.getAccessToken();
  final refreshToken = await TokenStorage.getRefreshToken();

  if (token == null) {
    print("⛔ No access token found (not guest).");
    return null;
  }

  print("🔑 Access token found: $token");

  // ✅ Decode only JWT token — skip if not valid JWT
  final isExpired = ApiClient.isTokenExpired(token);
  final isExpiringSoon = ApiClient.isTokenExpiringSoon(token, thresholdSeconds: 60);

  // ✅ Debug refresh token expiry
  if (refreshToken != null) {
    final isRefreshExpired = ApiClient.isTokenExpired(refreshToken);
    final refreshExpIn = ApiClient.getTokenExpiryInSeconds(refreshToken);
    print("🔄 Refresh token: $refreshToken");
    print("⏳ Refresh token expires in $refreshExpIn seconds | Expired: $isRefreshExpired");
  } else {
    print("⛔ No refresh token found.");
  }

  // ✅ 3. Decide Refresh Logic
  if (isExpired) {
    print("⏳ Access token expired! Refreshing now...");
    return await _refreshToken(token);
  } else if (isExpiringSoon) {
    print("⚠️ Access token expiring soon — refreshing silently.");
    _refreshToken(token); // 🔹 Non-blocking background refresh
    return token;
  } else {
    print("✅ Access token valid — continue API request.");
    return token;
  }
}

  /// ✅ Refresh token safely
  static Future<String?> _refreshToken(String currentToken) async {
    if (_isRefreshing) {
      print("⏱️ Refresh already in progress. Queuing request...");
      final completer = Completer<String>();
      _queue.add((newToken) {
        print("📥 Queued request resolved with token: $newToken");
        completer.complete(newToken);
      });
      return completer.future;
    }

    _isRefreshing = true;

    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      print("⛔ No refresh token available. Cannot refresh.");
      _isRefreshing = false;
      _resolveQueue('');
      return null;
    }

    print("🔄 Refreshing token using refresh token: $refreshToken");

    try {
      final body = {"refresh_token": refreshToken};
      print("📨 Sending body → $body");

      final response = await _dio.post(
        "refreshToken",
        data: body,
        options: Options(validateStatus: (_) => true),
      );

      print("📡 Refresh response → ${response.data}");
      print("📡 Status → ${response.statusCode}");
      print("📩 Headers sent → ${response.requestOptions.headers}");

      if (response.statusCode == 200 && response.data["code"] == 1) {
        await TokenStorage.saveSession({
          "access_token": response.data["access_token"],
          "refresh_token": response.data["refresh_token"],
          "user": response.data["user"],
        });

        final newToken = response.data["access_token"];
        print("✅ Token refreshed successfully: $newToken");
        _resolveQueue(newToken);
        _isRefreshing = false;
        return newToken;
      } else {
        SessionManager.clearSession(NavigatorService.context!);
        print("⚠️ Refresh failed — message: ${response.data["message"]}");
        print("❌ Full response data: ${response.data}");
        _isRefreshing = false;
        _resolveQueue('');
        return null;
      }
    } catch (e, s) {
        
      print("❌ Exception during token refresh: $e");
      print("🧩 Stacktrace: $s");
      _isRefreshing = false;
      _resolveQueue('');
      return null;
    }
  }

  /// ✅ Resolve queued requests safely
  static void _resolveQueue(String token) {
    for (final cb in _queue) {
      try {
        cb(token);
      } catch (_) {}
    }
    _queue.clear();
  }

  // popular picks
  
}



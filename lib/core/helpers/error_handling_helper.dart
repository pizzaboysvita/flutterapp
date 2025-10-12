import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  /// Returns a user-friendly error message from any [error]
  static String handle(dynamic error, {String? fallbackMessage}) {
    String errorMessage = fallbackMessage ?? "An unexpected error occurred.";

    // 🔌 Socket (No Internet)
    if (error is SocketException) {
      errorMessage = "No internet connection. Please check your network.";
    }
    // ⏳ Timeout
    else if (error is TimeoutException) {
      errorMessage = "The request timed out. Please try again.";
    }
    // 🌐 Dio Errors (API/HTTP)
    else if (error is DioException) {
      if (error.response != null) {
        final status = error.response?.statusCode;
        final msg = error.response?.data?["message"];

        if (status == 400) {
          errorMessage = msg ?? "Invalid request. Please check your input.";
        } else if (status == 401) {
          errorMessage = msg ?? "Unauthorized. Please login again.";
        } else if (status == 403) {
          errorMessage = msg ?? "Access denied. You don’t have permission.";
        } else if (status == 404) {
          errorMessage = msg ?? "Requested resource not found.";
        } else if (status == 500) {
          errorMessage = "Server error. Please try again later.";
        } else {
          errorMessage = msg ?? "Unexpected error occurred (Status $status).";
        }
      } else {
        errorMessage = "Network error. Please try again.";
      }
    }
    // 🔎 Unknown Errors
    else {
      errorMessage = error.toString();
    }

    return errorMessage;
  }
}

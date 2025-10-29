// ignore_for_file: unused_field

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/internet_check_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_event.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/error_screen_tracker.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';
import 'package:pizza_boys/core/helpers/internet_helper/network_issue_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/server_error_helper.dart';


class ErrorNotifier {
  static bool isShowingServerError = false;

  /// Show a quick global server error without needing options
  static void showServerError(String message) {
    showErrorScreen(
      RequestOptions(path: ''),
      message,
      ErrorScreenType.server,
      true,
    );
  }

  /// Centralized UI error screen display
  static Future<void> showErrorScreen(
    RequestOptions options,
    String message,
    ErrorScreenType type,
    bool hasInternet,
  ) async {
    final ctx = NavigatorService.context;
    if (ctx == null) return;

    // Prevent multiple overlapping server/network error screens
    if (ErrorScreenTracker.isShowing || ApiClient.isShowingServerError) return;
    ApiClient.isShowingServerError = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasInternet) {
        // 🌐 Network issue — show network error screen
        if (ErrorScreenTracker.canShow(ErrorScreenType.network)) {
          ErrorScreenTracker.set(ErrorScreenType.network);
          Navigator.of(ctx, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => NetworkIssueScreen(
                onRetry: () async {
                  // ✅ Reset flags so future errors can show properly
                  ApiClient.isShowingServerError = false;
                  ErrorScreenTracker.reset();

                  // Close this screen before retrying
                  Navigator.pop(ctx);

                  // Optional: trigger connectivity recheck
                  try {
                    BlocProvider.of<ConnectivityBloc>(ctx).recheckConnection();
                  } catch (_) {}
                },
              ),
            ),
            (route) => false,
          );
        }
      } else {
        // 🔥 Server error — show server timeout screen
        if (ErrorScreenTracker.canShow(type)) {
          ErrorScreenTracker.set(type);
          Navigator.of(ctx, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) {
                  final serverBloc = ServerTimeoutBloc(
                    dio: ApiClient.dio,
                    requestOptions: options,
                  );

                  // Automatically try a retry
                  serverBloc.add(RetryRequestEvent());

                  return serverBloc;
                },
                child: Builder(
                  builder: (context) {
                    final serverBloc =
                        BlocProvider.of<ServerTimeoutBloc>(context);
                    return ServerTimeoutScreen(
                      bloc: serverBloc,
                      errorMessage: message, // ✅ correct parameter name
                      onClose: () {
                        // ✅ Clean all flags when closing
                        isShowingServerError = false;
                        ApiClient.isShowingServerError = false;
                        ErrorScreenTracker.reset();
                      },
                    );
                  },
                ),
              ),
            ),
            (route) => false,
          );
        }
      }
    });
  }
}

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

  if (ErrorScreenTracker.isShowing || ApiClient.isShowingServerError) return;
  ApiClient.isShowingServerError = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!hasInternet) {
      if (ErrorScreenTracker.canShow(ErrorScreenType.network)) {
        ErrorScreenTracker.set(ErrorScreenType.network);
        Navigator.of(ctx, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => NetworkIssueScreen(
              onRetry: () async {
                ErrorScreenTracker.reset();
                Navigator.pop(ctx);
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

                // Auto retry
                serverBloc.add(RetryRequestEvent());

                return serverBloc;
              },
              child: Builder(
                builder: (context) {
                  final serverBloc =
                      BlocProvider.of<ServerTimeoutBloc>(context);
                  return ServerTimeoutScreen(
                    bloc: serverBloc,
                    errorMessage: message,
                    onClose: () {
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

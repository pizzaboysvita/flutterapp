// server_error_helper.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/server_error_helper.dart';


class ServerErrorHandler {
  static void showServerError(BuildContext context, String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServerTimeoutScreen(
          bloc: ServerTimeoutBloc(
            dio: ApiClient.dio,
            requestOptions: RequestOptions(path: "refreshToken"),
          ),
          errorMessage: message,
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

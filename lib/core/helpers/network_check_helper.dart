import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void startMonitoring(BuildContext context) {
    _subscription = _connectivity.onConnectivityChanged.listen((statuses) {
      // 'statuses' is now List<ConnectivityResult>
      final status = statuses.isNotEmpty ? statuses.first : ConnectivityResult.none;

      if (status == ConnectivityResult.none) {
        _showNoConnectionSnackbar(context);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _showNoConnectionSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("⚠️ No network connection. Please try again."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // sticky until network returns
        action: SnackBarAction(
          label: "Retry",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

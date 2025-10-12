import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'internet_check_event.dart';
import 'internet_check_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>>
  _subscription; // ✅ v7 returns List
  final Dio _dio = Dio();

  ConnectivityBloc() : super(ConnectivityState.initial()) {
    on<ConnectivityChanged>((event, emit) {
      emit(ConnectivityState(hasInternet: event.hasInternet));
    });

    // ✅ Listen for network changes (List<ConnectivityResult>)
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        _handleConnectivityChange(results.first); // Take first result
      } else {
        _handleConnectivityChange(ConnectivityResult.none);
      }
    });

    // Initial check
    _initCheck();
  }

  /// Handle connectivity change events
  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    bool hasInternet = false;

    if (result != ConnectivityResult.none) {
      hasInternet = await _checkInternet();
    }

    add(ConnectivityChanged(hasInternet));
  }

  /// Initial connectivity + internet check
  Future<void> _initCheck() async {
    final results = await _connectivity
        .checkConnectivity(); // ✅ returns List<ConnectivityResult>
    if (results.isNotEmpty) {
      _handleConnectivityChange(results.first);
    } else {
      _handleConnectivityChange(ConnectivityResult.none);
    }
  }

  /// Recheck manually (Retry button)
  Future<void> recheckConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty) {
      _handleConnectivityChange(results.first);
    } else {
      _handleConnectivityChange(ConnectivityResult.none);
    }
  }

  /// Lightweight internet check
  Future<bool> _checkInternet() async {
    try {
      final response = await _dio.get(
        'https://www.google.com/generate_204',
        options: Options(
          sendTimeout: const Duration(seconds: 2), // ✅ Duration not int
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

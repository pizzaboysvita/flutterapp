import 'package:bloc/bloc.dart';

import 'package:dio/dio.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_event.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_state.dart';

class ServerTimeoutBloc extends Bloc<ServerTimeoutEvent, ServerTimeoutState> {
  final Dio dio;
  final RequestOptions requestOptions;

  ServerTimeoutBloc({required this.dio, required this.requestOptions})
      : super(ServerTimeoutInitial()) {
    on<RetryRequestEvent>(_onRetry);
  }

  Future<void> _onRetry(
      RetryRequestEvent event, Emitter<ServerTimeoutState> emit) async {
    emit(ServerTimeoutLoading());

    try {
      await dio.fetch(requestOptions); // Retry API call
      emit(ServerTimeoutSuccess());
    } catch (_) {
      emit(ServerTimeoutFailure());
    }
  }
}

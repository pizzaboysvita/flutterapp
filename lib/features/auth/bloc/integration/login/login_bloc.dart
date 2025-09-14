import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/auth/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo repository;

  LoginBloc(this.repository) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      print("LoginButtonPressed event triggered"); // Debug log
      emit(LoginLoading());
      try {
        print("Calling repository.loginUser with email: ${event.email}");
        final data = await repository.loginUser(event.email, event.password);
        print("Login response data: $data"); // Debug log

        if (data["code"] == "1") {
          print("Login success, saving session...");
          await TokenStorage.saveSession(data);
          emit(LoginSuccess(data));
        } else {
          print("Login failed with message: ${data["message"]}");
          emit(LoginFailure(data["message"] ?? "Unknown error"));
        }
      } catch (error) {
    String errorMessage = "An unexpected error occurred.";

    if (error is SocketException) {
      errorMessage = "No internet connection. Please check your network.";
    } else if (error is TimeoutException) {
      errorMessage = "The request timed out. Please try again.";
    } else if (error is ClientException) {
      errorMessage = "Server is unreachable. Please try later.";
    } else if (error is Exception) {
      errorMessage = error.toString();
    }

    emit(LoginFailure(errorMessage));  // ✅ Here you emit the failure
  }
    });
  }
}

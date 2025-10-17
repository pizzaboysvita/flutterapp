import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/auth/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo repository;

  LoginBloc(this.repository) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    // login_bloc.dart
    on<GuestLoginEvent>((event, emit) async {
      emit(LoginLoading());
      try {
        await repository.guestLogin();
        emit(LoginSuccess(isGuest: true));
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final data = await repository.loginUser(event.email, event.password);

      if (data["code"] == 1) {
        await TokenStorage.saveSession(data);
        emit(LoginSuccess(data: data));
      } else {
        emit(LoginFailure(data["message"] ?? "Unknown error"));
      }
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }
}

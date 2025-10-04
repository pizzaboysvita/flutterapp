import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/auth/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo repository;

  LoginBloc(this.repository) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    print("🎯 [LoginBloc] LoginButtonPressed triggered");
    emit(LoginLoading());

    try {
      final data = await repository.loginUser(event.email, event.password);
      print("📥 [LoginBloc] Repository returned: $data");

      if (data["code"] == 1) {
        print("✅ [LoginBloc] Login success, saving session...");
        await TokenStorage.saveSession(data);
        emit(LoginSuccess(data));
      } else {
        print("❌ [LoginBloc] Backend error: ${data["message"]}");
        emit(LoginFailure(data["message"] ?? "Unknown error"));
      }
    } catch (error) {
      print("🔥 [LoginBloc] Exception caught: $error");
      emit(LoginFailure(error.toString()));
    }
  }
}

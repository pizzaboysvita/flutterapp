import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/auth/login_repo.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo _repo;

  LoginBloc(this._repo) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginPressed);
    on<GuestLoginEvent>(_onGuestLogin);
  }

  Future<void> _onLoginPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final data = await _repo.loginUser(event.email, event.password);
      emit(LoginSuccess(isGuest: false, data: data)); // ✅ fixed here
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onGuestLogin(
    GuestLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await _repo.guestLogin();
      emit(LoginSuccess(isGuest: true)); // ✅ guest flow no data
    } catch (e) {
      emit(LoginFailure("Guest login failed: $e"));
    }
  }
}

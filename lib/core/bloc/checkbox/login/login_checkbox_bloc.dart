// app_settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/checkbox/login/login_checkbox_event.dart';
import 'package:pizza_boys/core/bloc/checkbox/login/login_checkbox_state.dart';

class LoginCheckboxBloc extends Bloc<LoginCheckboxEvent, LoginCheckboxState> {
  LoginCheckboxBloc() : super(LoginCheckboxState()) {
    on<ToggleRememberMe>((event, emit) {
      emit(state.copyWith(rememberMe: !state.rememberMe));
    });
    on<ToggleAcceptTerms>((event, emit) {
      emit(state.copyWith(acceptTerms: !state.acceptTerms));
    });
  }
}

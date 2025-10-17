abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Map<String, dynamic>? data;
  final bool isGuest;

  LoginSuccess({this.data, this.isGuest = false});
}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}

abstract class UserState {}

class UserInitial extends UserState {}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

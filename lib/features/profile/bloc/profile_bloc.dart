import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/profile/user_repo.dart';
import 'package:pizza_boys/features/profile/bloc/profile_event.dart';
import 'package:pizza_boys/features/profile/bloc/profile_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepo repo;

  UserBloc(this.repo) : super(UserInitial()) {
    on<UpdateUserEvent>(_updateUser);
  }

  Future<void> _updateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(UserUpdating());

    try {
      final response = await repo.updateUser(
        updatedFields: event.fields,
        imageFile: event.image,
      );

      if (response.data["code"] == 1) {
        emit(UserUpdated());
      } else {
        emit(UserError(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

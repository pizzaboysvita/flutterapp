import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/profile/user_event.dart';
import 'package:pizza_boys/core/bloc/profile/user_state.dart';
import 'package:pizza_boys/data/repositories/profile/user_repo.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final UserRepo repo;

  DeleteAccountBloc(this.repo) : super(DeleteAccountInitial()) {
    on<DeleteAccountRequested>(_onDeleteAccount);
  }

  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<DeleteAccountState> emit,
  ) async {
    emit(DeleteAccountLoading());

    try {
      final response = await repo.deleteUserAccount();

      if (response.statusCode == 200 && response.data["code"] == 1) {
        emit(DeleteAccountSuccess(response.data["message"]));
      } else {
        emit(DeleteAccountFailure(response.data["message"] ?? "Delete failed"));
      }
    } catch (e) {
      emit(DeleteAccountFailure(e.toString()));
    }
  }
}

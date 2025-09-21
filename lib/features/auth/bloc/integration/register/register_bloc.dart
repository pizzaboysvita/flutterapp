import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/auth/register_repo.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository repo;

  RegisterBloc(this.repo) : super(RegisterInitial()) {
    on<SubmitRegister>((event, emit) async {
      emit(RegisterLoading());
      try {
        final result = await repo.register(
          firstName: event.firstName,
          lastName: event.lastName,
          phone: event.phone,
          email: event.email,
          password: event.password,
          address: event.address,
          country: event.country,
          state: event.state,
          city: event.city,
          pinCode: event.pinCode,
          imageFile: event.imageFile,
        );
        emit(RegisterSuccess(result));
        
      } catch (e) {
        emit(RegisterFailure(e.toString()));
      }
    });
  }
}

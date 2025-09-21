import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_event.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_state.dart';

class PsObscureBloc extends Bloc<PsObscureEvent, PsObscureState> {
  PsObscureBloc() : super(PsObscureValue(true)) {
    // ObscureText
    on<ObscureText>((event, emit) {
      final current = (state as PsObscureValue).obscure;
      emit(PsObscureValue(!current));
    });
  }
}

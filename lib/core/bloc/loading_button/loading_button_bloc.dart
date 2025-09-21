

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_event.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_state.dart';

class LoadingButtonBloc extends Bloc<LoadingBtnEvent, LoadingBtnState> {
  LoadingButtonBloc() : super(ButtonIdle()) {
    on<ButtonPressed>((event, emit) async {
      emit(ButtonLoading());
      try {
        if (event.onPressedAsync != null) {
          await event.onPressedAsync!();
        }
        emit(ButtonSuccess());
      } catch (_) {
        emit(ButtonError());
      } finally {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(ButtonIdle());
      }
    });
  }
}

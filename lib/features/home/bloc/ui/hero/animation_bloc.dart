import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/hero/animation_event.dart';
import 'package:pizza_boys/features/home/bloc/ui/hero/animation_state.dart';

class BikeAnimationBloc extends Bloc<BikeAnimationEvent, BikeAnimationState> {
  BikeAnimationBloc() : super(BikeAnimationInitial()) {
    on<StartBikeAnimation>((event, emit) {
      emit(BikeAnimationStarted());
    });

    on<StopBikeAnimation>((event, emit) {
      emit(BikeAnimationStopped());
    });
  }
}

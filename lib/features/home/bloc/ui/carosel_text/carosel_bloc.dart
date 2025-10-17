import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/carosel_text/carosel_event.dart';
import 'package:pizza_boys/features/home/bloc/ui/carosel_text/carosel_state.dart';

class CarouselTextBloc extends Bloc<CarouselTextEvent, CarouselTextState> {
  Timer? _timer;
  final int totalSlides;

  CarouselTextBloc(this.totalSlides) : super(CarouselInitial()) {
    on<StartCarousel>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        add(NextCarouselSlide());
      });
    });

    on<NextCarouselSlide>((event, emit) {
      int nextIndex = (state.currentIndex + 1) % totalSlides;
      emit(CarouselSlideChanged(nextIndex));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

// banner_carousel_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_event.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_state.dart';


class BannerCarouselBloc extends Bloc<BannerCarouselEvent, BannerCarouselState> {
  BannerCarouselBloc() : super(BannerCarouselState(currentIndex: 0)) {
    on<BannerPageChanged>((event, emit) {
      emit(state.copyWith(currentIndex: event.index));
    });
  }
}

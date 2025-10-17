// banner_carousel_state.dart
class BannerCarouselState {
  final int currentIndex;

  const BannerCarouselState({required this.currentIndex});

  BannerCarouselState copyWith({int? currentIndex}) {
    return BannerCarouselState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

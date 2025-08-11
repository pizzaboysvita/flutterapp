// banner_carousel_event.dart
abstract class BannerCarouselEvent {}

class BannerPageChanged extends BannerCarouselEvent {
  final int index;

  BannerPageChanged(this.index);
}

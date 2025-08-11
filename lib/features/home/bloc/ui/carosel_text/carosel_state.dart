abstract class CarouselTextState {
  final int currentIndex;
  CarouselTextState(this.currentIndex);
}

class CarouselInitial extends CarouselTextState {
  CarouselInitial() : super(0);
}

class CarouselSlideChanged extends CarouselTextState {
  CarouselSlideChanged(super.index);
}

// combo_details_event.dart
abstract class ComboDetailsEvent {}

class ToggleSideExpandEvent extends ComboDetailsEvent {
  final int sideIndex;
  ToggleSideExpandEvent(this.sideIndex);
}

class ToggleDishSelectEvent extends ComboDetailsEvent {
  final int sideIndex;
  final int categoryId;
  final int dishId;
  ToggleDishSelectEvent({
    required this.sideIndex,
    required this.categoryId,
    required this.dishId,
  });
}

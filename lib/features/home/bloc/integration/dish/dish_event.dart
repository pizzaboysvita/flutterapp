abstract class DishEvent {}

class GetAllDishesEvent extends DishEvent {
  final int ?categoryId;

  GetAllDishesEvent({this.categoryId});
}

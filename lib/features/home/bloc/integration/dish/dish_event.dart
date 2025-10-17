abstract class DishEvent {}

class GetAllDishesEvent extends DishEvent {
  final String storeId;
  final int? categoryId;
  final bool? showLoading;

  GetAllDishesEvent({required this.storeId, this.categoryId, this.showLoading});
}

class ClearDishesEvent extends DishEvent {}

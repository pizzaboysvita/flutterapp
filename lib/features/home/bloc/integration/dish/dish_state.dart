import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class DishState {}

class DishInitial extends DishState {}

class DishLoading extends DishState {}

class DishLoaded extends DishState {
  final List<DishModel> dishes;
  DishLoaded(this.dishes);
}

class DishError extends DishState {
  final String message;
  DishError(this.message);
}

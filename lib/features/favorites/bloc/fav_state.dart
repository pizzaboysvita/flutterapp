import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<DishModel> favorites;
  FavoriteLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}

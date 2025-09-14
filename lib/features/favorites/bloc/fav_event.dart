import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class FavoriteEvent {}

class AddToFavoriteEvent extends FavoriteEvent {
  final DishModel dish;
  AddToFavoriteEvent(this.dish);
}

class RemoveFromFavoriteEvent extends FavoriteEvent {
  final int dishId;
  RemoveFromFavoriteEvent(this.dishId);
}

class LoadFavoritesEvent extends FavoriteEvent {}

// Get Api Event
class FetchWishlistEvent extends FavoriteEvent {}

import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class FavoriteEvent {}

class AddToFavoriteEvent extends FavoriteEvent {
  final DishModel dish;
  AddToFavoriteEvent(this.dish);
}

class RemoveFromFavoriteEvent extends FavoriteEvent {
  final int dishId;
  final int? wishlistId; // ✅ now optional

  RemoveFromFavoriteEvent({
    required this.dishId,
    this.wishlistId,
  });
}



class LoadFavoritesEvent extends FavoriteEvent {}

// Get Api Event
class FetchWishlistEvent extends FavoriteEvent {}

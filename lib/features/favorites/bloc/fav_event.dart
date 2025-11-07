import 'package:equatable/equatable.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class AddToFavoriteEvent extends FavoriteEvent {
  final DishModel dish;
  const AddToFavoriteEvent(this.dish);

  @override
  List<Object?> get props => [dish];
}

class RemoveFromFavoriteEvent extends FavoriteEvent {
  final DishModel? dish;
  final int? wishlistId;

  const RemoveFromFavoriteEvent({this.dish, this.wishlistId});

  @override
  List<Object?> get props => [dish, wishlistId];
}

class LoadFavoritesEvent extends FavoriteEvent {
  const LoadFavoritesEvent();
}

class FetchWishlistEvent extends FavoriteEvent {
  final String? storeId;
  const FetchWishlistEvent({this.storeId});
}

/// ❌ Clear favorites (guest or user)
class ClearFavoritesEvent extends FavoriteEvent {
  const ClearFavoritesEvent();
}

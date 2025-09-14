import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/repositories/whishlist/whishlist_repo.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_state.dart';


class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;
  final List<DishModel> _favorites = [];

  FavoriteBloc({
    required this.repository,
  }) : super(FavoriteInitial()) {
    on<AddToFavoriteEvent>(_onAdd);
    on<RemoveFromFavoriteEvent>(_onRemove);
    on<LoadFavoritesEvent>(_onLoad);
    on<FetchWishlistEvent>(_onFetchWishlist);
  }

  Future<void> _onAdd(AddToFavoriteEvent event, Emitter<FavoriteState> emit) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("Token not available");
print("🔑 Token: $token");

      final success = await repository.toggleFavorite(
        dishId: event.dish.id,
        token: token,
      );

      if (success) {
        if (!_favorites.any((d) => d.id == event.dish.id)) {
          _favorites.add(event.dish);
        }
        emit(FavoriteLoaded(List.from(_favorites)));
      } else {
        emit(FavoriteError("Failed to add to favorites"));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onRemove(RemoveFromFavoriteEvent event, Emitter<FavoriteState> emit) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("Token not available");

      final success = await repository.toggleFavorite(
        dishId: event.dishId,
        token: token,
      );

      if (success) {
        _favorites.removeWhere((d) => d.id == event.dishId);
        emit(FavoriteLoaded(List.from(_favorites)));
      } else {
        emit(FavoriteError("Failed to remove from favorites"));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onLoad(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    emit(FavoriteLoaded(List.from(_favorites)));
  }

Future<void> _onFetchWishlist(FetchWishlistEvent event, Emitter<FavoriteState> emit) async {
  emit(FavoriteLoading());
  try {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token not available");
    print("🔑 Token found: $token");

    final wishlist = await repository.getWishlist(token: token);
    print("📦 Wishlist fetched, count: ${wishlist.length}");

    _favorites.clear();
    _favorites.addAll(wishlist);

    emit(FavoriteLoaded(List.from(_favorites)));
  } catch (e, stacktrace) {
    print("❌ Error fetching wishlist: $e");
    print(stacktrace);
    emit(FavoriteError(e.toString()));
  }
}

}

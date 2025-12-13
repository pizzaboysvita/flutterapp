import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/repositories/whishlist/whishlist_repo.dart';
import 'fav_event.dart';
import 'fav_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repository;
  final StoreWatcherCubit storeWatcherCubit;
  late final StreamSubscription<String?> storeSub;

  final List<DishModel> _favorites = [];

  FavoriteBloc({required this.repository, required this.storeWatcherCubit})
    : super(FavoriteInitial()) {
    on<AddToFavoriteEvent>(_onAdd);
    on<RemoveFromFavoriteEvent>(_onRemove);
    on<LoadFavoritesEvent>(_onLoad);
    on<FetchWishlistEvent>(_onFetchWishlist);
    on<ClearFavoritesEvent>(_onClear);

    // Listen to store changes and refresh favorites
    storeSub = storeWatcherCubit.stream.listen((storeId) {
      if (storeId != null) add(FetchWishlistEvent());
    });
  }

  /// ➕ Add to favorites with optimistic update
  Future<void> _onAdd(
    AddToFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final dish = event.dish;

    // ⭐ optimistic UI update
    if (!_favorites.any((d) => d.id == dish.id)) {
      _favorites.add(dish);
      emit(FavoriteLoaded(List.from(_favorites)));
    }

    try {
      await repository.addFavorite(dish);
    } catch (e) {
      // rollback if failed
      _favorites.removeWhere((d) => d.id == dish.id);
      emit(FavoriteError("Failed to add favorite"));
    }
  }

  /// ➖ Remove from favorites with optimistic update
  Future<void> _onRemove(
    RemoveFromFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    final dish = event.dish!;
    final wishlistId = event.wishlistId;

    // ⭐ optimistic update
    _favorites.removeWhere((d) => d.id == dish.id);
    emit(FavoriteLoaded(List.from(_favorites)));

    try {
      final success = await repository.removeFavorite(dish, wishlistId);

      if (!success) {
        _favorites.add(dish); // rollback
        emit(FavoriteError("Failed to remove from favorites"));
        return;
      }

      final favs = await repository.getFavorites();
      _favorites
        ..clear()
        ..addAll(favs);
      emit(FavoriteLoaded(List.from(_favorites)));
    } catch (e) {
      _favorites.add(dish); // rollback
      emit(FavoriteError(e.toString()));
    }
  }

  /// 📦 Load favorites from guest/local or API
  Future<void> _onLoad(
    LoadFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      _favorites.clear();
      final favs = await repository.getFavorites();
      _favorites.addAll(favs);
      emit(FavoriteLoaded(List.from(_favorites)));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  /// 🌐 Refresh wishlist (fetch from API or local)
  Future<void> _onFetchWishlist(
    FetchWishlistEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final favs = await repository.getFavorites();

      _favorites
        ..clear()
        ..addAll(favs);

      emit(FavoriteLoaded(List.from(_favorites)));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  /// ❌ Clear all favorites (guest or user)
  Future<void> _onClear(
    ClearFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    _favorites.clear();
    emit(FavoriteLoaded([]));

    // Repository will detect guest or logged-in automatically
    await repository.clearFavorites();
  }

  /// Clear favorites (used anywhere - guest or user)
  Future<void> clearFavorites() async {
    add(const ClearFavoritesEvent());
  }

  // to get whishlist ids for dishes
  DishModel? getFavoriteDishById(int dishId) {
    print(
      "🔍 Searching favorite for dishId: $dishId in ${_favorites.length} favorites...",
    );

    for (var d in _favorites) {
      print(
        "   👉 Checking favorite: dishId=${d.id}, wishlistId=${d.wishlistId}",
      );
    }

    try {
      final match = _favorites.firstWhere((d) => d.id == dishId);
      print(
        "🎯 MATCHED favorite dish: ${match.id} wishlistId=${match.wishlistId}",
      );
      return match;
    } catch (_) {
      print("❌ No match found for dishId: $dishId");
      return null;
    }
  }

  Future<void> fetchAndRemove(DishModel dish) async {
    final storeId = storeWatcherCubit.state;
    add(FetchWishlistEvent(storeId: storeId));

    await Future.delayed(Duration(milliseconds: 200));

    await repository.getFavorites(); // fresh data
    final match = getFavoriteDishById(dish.id);

    if (match?.wishlistId != null) {
      add(RemoveFromFavoriteEvent(dish: dish, wishlistId: match!.wishlistId));
    }
  }

  @override
  Future<void> close() {
    storeSub.cancel();
    return super.close();
  }
}

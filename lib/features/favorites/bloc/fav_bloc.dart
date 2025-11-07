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
  Future<void> _onAdd(AddToFavoriteEvent event, Emitter<FavoriteState> emit) async {
    final dish = event.dish;
    if (!_favorites.any((d) => d.id == dish.id)) {
      _favorites.add(dish); // optimistic update
      emit(FavoriteLoaded(List.from(_favorites)));
    }

    try {
      final success = await repository.addFavorite(dish);
      if (!success) {
        _favorites.removeWhere((d) => d.id == dish.id); // rollback
        emit(FavoriteError("Failed to add to favorites"));
      }
    } catch (e) {
      _favorites.removeWhere((d) => d.id == dish.id); // rollback
      emit(FavoriteError(e.toString()));
    }
  }

  /// ➖ Remove from favorites with optimistic update
  Future<void> _onRemove(RemoveFromFavoriteEvent event, Emitter<FavoriteState> emit) async {
    final dish = event.dish!;
    _favorites.removeWhere((d) => d.id == dish.id); // optimistic
    emit(FavoriteLoaded(List.from(_favorites)));

    try {
      final success = await repository.removeFavorite(dish);
      if (!success) {
        _favorites.add(dish); // rollback
        emit(FavoriteError("Failed to remove from favorites"));
      }
    } catch (e) {
      _favorites.add(dish); // rollback
      emit(FavoriteError(e.toString()));
    }
  }

  /// 📦 Load favorites from guest/local or API
  Future<void> _onLoad(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
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
Future<void> _onFetchWishlist(FetchWishlistEvent event, Emitter<FavoriteState> emit) async {
  emit(FavoriteLoading());
  try {
    _favorites.clear();

    final favs = await repository.getFavorites();

    // 🔹 Use storeId from event, fallback to cubit state
    final currentStoreId = event.storeId ?? storeWatcherCubit.state;
    final filteredFavs = favs.where((dish) => dish.storeId.toString() == currentStoreId).toList();

    _favorites.addAll(filteredFavs);
    emit(FavoriteLoaded(List.from(_favorites)));
    print("✅ Fetched favorites for store: $currentStoreId → ${_favorites.length}");
  } catch (e) {
    emit(FavoriteError(e.toString()));
    print("❌ Failed to fetch favorites: $e");
  }
}




  /// ❌ Clear all favorites (guest or user)
  Future<void> _onClear(ClearFavoritesEvent event, Emitter<FavoriteState> emit) async {
    _favorites.clear();
    emit(FavoriteLoaded([]));

    // Repository will detect guest or logged-in automatically
    await repository.clearFavorites();
  }

  /// Clear favorites (used anywhere - guest or user)
  Future<void> clearFavorites() async {
    add(const ClearFavoritesEvent());
  }


  @override
  Future<void> close() {
    storeSub.cancel();
    return super.close();
  }
}

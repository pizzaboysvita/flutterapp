import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
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

    // 🧩 Listen for store change
    storeSub = storeWatcherCubit.stream.listen((storeId) async {
      if (storeId != null) {
        print("🏪 [FavoriteBloc] Store changed → $storeId");

        /// ✅ Just trigger the event — don't call emit() directly
        add(FetchWishlistEvent());
      }
    });
  }

  // ➕ Add to favorites
  Future<void> _onAdd(
    AddToFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("Token not available");

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

  // ➖ Remove from favorites
  Future<void> _onRemove(
    RemoveFromFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("Token not available");

      final success = await repository.removeFavorite(
        dishId: event.dishId,
        wishlistId: event.wishlistId,
        token: token,
      );

      if (success) {
        _favorites.removeWhere((d) => d.wishlistId == event.wishlistId);
        emit(FavoriteLoaded(List.from(_favorites)));
      } else {
        emit(FavoriteError("Failed to remove from favorites"));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  // 📦 Load local favorites
  Future<void> _onLoad(
    LoadFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoaded(List.from(_favorites)));
  }

  // 🌐 Fetch wishlist from API
  Future<void> _onFetchWishlist(
    FetchWishlistEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) throw Exception("Token not available");

      final wishlist = await repository.getWishlist();

      // 🏪 Get current store
      final currentStoreId = await TokenStorage.getChosenStoreId();

      // 🔍 Filter only items matching this store
      final filtered = wishlist
          .where((item) => item.storeId.toString() == currentStoreId)
          .toList();

      print('📍filtered fav items based on store filter: $filtered');

      _favorites
        ..clear()
        ..addAll(filtered);

      print(
        "✅ [FavoriteBloc] Wishlist filtered for store $currentStoreId (${_favorites.length} items)",
      );
      emit(FavoriteLoaded(List.from(_favorites)));
    } catch (e) {
      print("❌ [FavoriteBloc] Failed to fetch wishlist: $e");
      emit(FavoriteError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    storeSub.cancel();
    return super.close();
  }
}

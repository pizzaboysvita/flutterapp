import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final List<DishModel> _favorites = [];

  // Use flutter_secure_storage
  static const _storage = FlutterSecureStorage();
  static const _favoritesKey = "favorite_dishes";

  FavoriteBloc() : super(FavoriteInitial()) {
    on<AddToFavoriteEvent>(_onAdd);
    on<RemoveFromFavoriteEvent>(_onRemove);
    on<LoadFavoritesEvent>(_onLoad);

    add(LoadFavoritesEvent()); // load saved favorites on startup
  }

  Future<void> _onAdd(AddToFavoriteEvent event, Emitter<FavoriteState> emit) async {
    if (!_favorites.any((d) => d.id == event.dish.id)) {
      _favorites.add(event.dish);
      await _saveFavorites();
    }
    emit(FavoriteLoaded(List.from(_favorites)));
  }

  Future<void> _onRemove(RemoveFromFavoriteEvent event, Emitter<FavoriteState> emit) async {
    _favorites.removeWhere((d) => d.id == event.dishId);
    await _saveFavorites();
    emit(FavoriteLoaded(List.from(_favorites)));
  }

  Future<void> _onLoad(LoadFavoritesEvent event, Emitter<FavoriteState> emit) async {
    final favJsonStr = await _storage.read(key: _favoritesKey);
    if (favJsonStr != null) {
      final List<dynamic> decoded = jsonDecode(favJsonStr);
      _favorites.clear();
      for (var map in decoded) {
        _favorites.add(DishModel.fromJson(map));
      }
    }
    emit(FavoriteLoaded(List.from(_favorites)));
  }

  Future<void> _saveFavorites() async {
    final favJson = _favorites.map((d) => d.toJson()).toList();
    await _storage.write(key: _favoritesKey, value: jsonEncode(favJson));
  }
}

// lib/features/fav/bloc/fav_state.dart
import 'package:equatable/equatable.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

// Used when returning the list of favorites
class FavoriteLoaded extends FavoriteState {
  final List<DishModel> favorites;
  const FavoriteLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

// Generic success (e.g. added/removed message)
class FavoriteSuccess extends FavoriteState {
  final Map<String, dynamic> response;
  const FavoriteSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class FavoriteError extends FavoriteState {
  final String message;
  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}

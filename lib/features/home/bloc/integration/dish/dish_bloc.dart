import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'dish_event.dart';
import 'dish_state.dart';

class DishBloc extends Bloc<DishEvent, DishState> {
  final DishRepository repository;

  DishBloc(this.repository) : super(DishInitial()) {
    on<GetAllDishesEvent>((event, emit) async {
      emit(DishLoading());
      try {
        final dishes = await repository.getAllDishes();
        emit(DishLoaded(dishes));
      } catch (e) {
        emit(DishError(e.toString()));
      }
    });
  }
}

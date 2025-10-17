import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/internet_helper/global_error_handler.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'dish_event.dart';
import 'dish_state.dart';

class DishBloc extends Bloc<DishEvent, DishState> {
  final DishRepository repository;
  final StoreWatcherCubit storeWatcherCubit;
  late final StreamSubscription<String?> storeSub;

  DishBloc(this.repository, this.storeWatcherCubit) : super(DishInitial()) {
    on<GetAllDishesEvent>(_onGetAllDishes);

    on<ClearDishesEvent>((event, emit) {
      emit(DishLoading());
    });

    storeSub = storeWatcherCubit.stream.listen((storeId) {
      if (storeId != null) {
        repository.clearCache(); // Clear cache when store changes
        add(ClearDishesEvent());
        add(GetAllDishesEvent(storeId: storeId));
      }
    });

    //  Initial load from TokenStorage
    _loadInitialDishes();
  }

  Future<void> _loadInitialDishes() async {
    final storeIdStr = await TokenStorage.getChosenStoreId();
    if (storeIdStr != null) {
      add(GetAllDishesEvent(storeId: storeIdStr));
    }
  }

  Future<void> _onGetAllDishes(
    GetAllDishesEvent event,
    Emitter<DishState> emit,
  ) async {
    emit(DishLoading());

    try {
      final dishes = await repository.getAllDishes(event.storeId);
      emit(DishLoaded(dishes));
    } catch (e, st) {
  //  Centralized global error handling
  GlobalErrorHandler.handleError(e, stackTrace: st);

  // Emit normal Bloc error to show loading/error state
  emit(DishError(e.toString()));
}

  }

  @override
  Future<void> close() {
    storeSub.cancel();
    return super.close();
  }
}

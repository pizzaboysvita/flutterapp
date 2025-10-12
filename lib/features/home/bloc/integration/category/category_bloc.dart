import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/error_handling.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  final StoreWatcherCubit storeWatcherCubit;
  late final StreamSubscription<String?> storeSub;

  CategoryBloc(this.repository, this.storeWatcherCubit)
      : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);

    on<ClearCategoriesEvent>((event, emit) {
      emit(CategoryLoading());
    });

    // Listen to store changes
    storeSub = storeWatcherCubit.stream.listen((storeId) {
      if (storeId != null) {
        add(ClearCategoriesEvent());
        add(LoadCategories(
          storeId: int.parse(storeId),
          type: "web",
          forceRefresh: true,
        ));
      }
    });

    // ✅ Initial load from TokenStorage
    _loadInitialCategories();
  }

  Future<void> _loadInitialCategories() async {
    final storeIdStr = await TokenStorage.getChosenStoreId();
    if (storeIdStr != null) {
      add(LoadCategories(
        storeId: int.parse(storeIdStr),
        type: "web",
        forceRefresh: true,
      ));
    }
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    if (state is CategoryLoaded && !(event.forceRefresh ?? false)) {
      return;
    }

    emit(CategoryLoading());

    try {
      final categories = await repository.getCategories(
        event.storeId,
        event.type,
        forceRefresh: event.forceRefresh ?? false,
      );
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    storeSub.cancel();
    return super.close();
  }
}

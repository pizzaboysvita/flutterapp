import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'category_event.dart';
import 'category_state.dart';

// category_bloc.dart
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      // ✅ Don't refetch if already loaded
      if (state is CategoryLoaded && !(event.forceRefresh ?? false)) {
        return;
      }

      emit(CategoryLoading());
      try {
        final categories =
            await repository.getCategories(event.userId, event.type,
                forceRefresh: event.forceRefresh ?? false);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}


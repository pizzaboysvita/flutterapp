import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      if (state is CategoryLoaded) return;

      emit(CategoryLoading());
      try {
        final categories = await repository.getCategories(event.userId, event.type);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}

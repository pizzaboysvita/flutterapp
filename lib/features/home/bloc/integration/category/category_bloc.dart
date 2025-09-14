import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/helpers/error_handling.dart';
import 'package:pizza_boys/data/repositories/category/category_repo.dart';
import 'category_event.dart';
import 'category_state.dart';

// category_bloc.dart
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      print("CategoryBloc: LoadCategories event triggered"); 

      if (state is CategoryLoaded && !(event.forceRefresh ?? false)) {
        print("CategoryBloc: Categories already loaded, skipping fetch");
        return;
      }

      emit(CategoryLoading());
      print("CategoryBloc: Emitting CategoryLoading state");

      try {
        final categories = await repository.getCategories(
          event.userId,
          event.type,
          forceRefresh: event.forceRefresh ?? false,
        );
        print("CategoryBloc: Categories fetched successfully, count = ${categories.length}");

        emit(CategoryLoaded(categories));
      } catch (e) {
       print("CategoryBloc: Exception occurred - $e");
  final message = getFriendlyErrorMessage(e);
  emit(CategoryError(message)); 
      }
    });
  }
}



import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/repositories/search/search_repo.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepo repository;

  SearchBloc(this.repository) : super(SearchState.initial()) {
    on<RemoveRecentSearchEvent>((event, emit) {
      final updated = List<String>.from(state.recentSearches)..remove(event.term);
      emit(state.copyWith(recentSearches: updated));
    });

    on<AddRecentSearchEvent>((event, emit) {
      final updated = List<String>.from(state.recentSearches);
      if (!updated.contains(event.term)) {
        updated.insert(0, event.term);
      }
      emit(state.copyWith(recentSearches: updated));
    });

    on<SearchQueryChanged>((event, emit) async {
      if (event.query.trim().isEmpty) return;
      emit(state.copyWith(isLoading: true, error: null));

      try {
        final results =
            await repository.searchDishes(storeId: event.storeId, query: event.query);
        emit(state.copyWith(results: results, isLoading: false));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
  }
}

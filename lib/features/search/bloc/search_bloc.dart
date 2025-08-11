import 'package:flutter_bloc/flutter_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchState.initial()) {
    on<RemoveRecentSearchEvent>((event, emit) {
      final updatedSearches = List<String>.from(state.recentSearches)
        ..remove(event.term);
      emit(state.copyWith(recentSearches: updatedSearches));
    });

    on<AddRecentSearchEvent>((event, emit) {
      final updated = List<String>.from(state.recentSearches);
      if (!updated.contains(event.term)) {
        updated.insert(0, event.term);
      }
      emit(state.copyWith(recentSearches: updated));
    });
  }
}

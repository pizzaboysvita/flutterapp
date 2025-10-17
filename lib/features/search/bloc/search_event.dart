abstract class SearchEvent {}

class AddRecentSearchEvent extends SearchEvent {
  final String term;
  AddRecentSearchEvent(this.term);
}

class RemoveRecentSearchEvent extends SearchEvent {
  final String term;
  RemoveRecentSearchEvent(this.term);
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final int storeId;
  SearchQueryChanged(this.query, this.storeId);
}

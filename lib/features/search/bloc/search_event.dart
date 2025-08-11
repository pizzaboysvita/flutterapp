abstract class SearchEvent {}

class RemoveRecentSearchEvent extends SearchEvent {
  final String term;
  RemoveRecentSearchEvent(this.term);
}

class AddRecentSearchEvent extends SearchEvent {
  final String term;
  AddRecentSearchEvent(this.term);
}

class SearchState {
  final List<String> recentSearches;

  SearchState({required this.recentSearches});

  factory SearchState.initial() => SearchState(
    recentSearches: ['Chicken Pizzas', 'Veg Pizzas', 'Seafood Pizzas'],
  );

  SearchState copyWith({List<String>? recentSearches}) {
    return SearchState(recentSearches: recentSearches ?? this.recentSearches);
  }
}

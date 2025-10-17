class SearchState {
  final List<String> recentSearches;
  final List<Map<String, dynamic>> results;
  final bool isLoading;
  final String? error;

  SearchState({
    required this.recentSearches,
    required this.results,
    required this.isLoading,
    this.error,
  });

  factory SearchState.initial() => SearchState(
        recentSearches: [],
        results: [],
        isLoading: false,
      );

  SearchState copyWith({
    List<String>? recentSearches,
    List<Map<String, dynamic>>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      recentSearches: recentSearches ?? this.recentSearches,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

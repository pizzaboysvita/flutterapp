abstract class CategoryEvent {}

// category_event.dart
class LoadCategories extends CategoryEvent {
  final int userId;
  final String type;
  final bool? forceRefresh; // ✅ Optional

  LoadCategories({required this.userId, required this.type, this.forceRefresh});
}


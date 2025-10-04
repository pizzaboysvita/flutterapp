abstract class CategoryEvent {}

// category_event.dart
class LoadCategories extends CategoryEvent {
  final int storeId;
  final String type;
  final bool? forceRefresh; // ✅ Optional

  LoadCategories({required this.storeId, required this.type, this.forceRefresh});
}


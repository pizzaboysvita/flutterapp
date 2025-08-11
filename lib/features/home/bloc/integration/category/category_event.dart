abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {
  final int userId;
  final String type;

  LoadCategories({required this.userId, required this.type});
}

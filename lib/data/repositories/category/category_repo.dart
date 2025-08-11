import 'package:pizza_boys/data/models/category/category_model.dart';
import 'package:pizza_boys/data/services/category/category_service.dart';

class CategoryRepository {
  final CategoryService _service;
  List<CategoryModel>? _cachedCategories;

  CategoryRepository(this._service);

  Future<List<CategoryModel>> getCategories(int userId, String type) async {
    if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    _cachedCategories = await _service.fetchCategories(
    );
    return _cachedCategories!;
  }
}

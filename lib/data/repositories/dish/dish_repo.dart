import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';

class DishRepository {
  final DishService service;
  List<DishModel>? _cachedDishes; // Local cache

  DishRepository(this.service);

  Future<List<DishModel>> getAllDishes(String storeId) async {
    if (_cachedDishes != null && _cachedDishes!.isNotEmpty) {
      return _cachedDishes!;
    }

    final rawData = await service.fetchAllDishes(storeId);
    _cachedDishes = rawData.map((e) => DishModel.fromJson(e)).toList();

    return _cachedDishes!;
  }

  Future<DishModel?> getDishById(int dishId, String storeId) async {
    if (_cachedDishes != null && _cachedDishes!.isNotEmpty) {
      final found = _cachedDishes!.firstWhere(
        (dish) => dish.id == dishId,
        orElse: () => DishModelExtensionsEmpty.empty(),
      );
      return found.id != null ? found : null;
    }

    final dishes = await getAllDishes(storeId);
    try {
      return dishes.firstWhere((dish) => dish.id == dishId);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshDishes(String storeId) async {
    final rawData = await service.fetchAllDishes(storeId);
    _cachedDishes = rawData.map((e) => DishModel.fromJson(e)).toList();
  }
}

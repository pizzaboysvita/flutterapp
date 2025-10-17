import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';

class DishRepository {
  final DishService service;
  List<DishModel>? _cachedDishes; // Local cache
  String? _lastStoreId; // Track which store's dishes are cached

  DishRepository(this.service);

  Future<List<DishModel>> getAllDishes(String storeId) async {
    if (_cachedDishes != null &&
        _cachedDishes!.isNotEmpty &&
        _lastStoreId == storeId) {
      // Return cache only if same store
      return _cachedDishes!;
    }

    final rawData = await service.fetchAllDishes(storeId);
    _cachedDishes = rawData.map((e) => DishModel.fromJson(e)).toList();
    _lastStoreId = storeId;

    print(
      "🔹 [DishRepository] Loaded ${_cachedDishes!.length} dishes for store $storeId",
    );
    return _cachedDishes!;
  }

  Future<DishModel?> getDishById(int dishId, String storeId) async {
    // Ensure cache is loaded for this store
    if (_cachedDishes == null || _lastStoreId != storeId) {
      await getAllDishes(storeId);
    }

    try {
      return _cachedDishes!.firstWhere((dish) => dish.id == dishId);
    } catch (e) {
      return null; // Dish not found
    }
  }

  Future<void> refreshDishes(String storeId) async {
    final rawData = await service.fetchAllDishes(storeId);
    _cachedDishes = rawData.map((e) => DishModel.fromJson(e)).toList();
    _lastStoreId = storeId;
  }

  void clearCache() {
    _cachedDishes = null;
    _lastStoreId = null;
  }
}

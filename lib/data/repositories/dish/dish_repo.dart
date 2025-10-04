import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';

class DishRepository {
  final DishService service;
  List<DishModel>? _cachedDishes; // 👈 Local cache

  DishRepository(this.service);

  /// Fetch all dishes (from cache if available)
  Future<List<DishModel>> getAllDishes() async {
    if (_cachedDishes != null && _cachedDishes!.isNotEmpty) {
      print("⚡ Using cached dishes (${_cachedDishes!.length})");
      return _cachedDishes!;
    }

    print("🌐 Fetching all dishes from API...");
    final rawData = await service.fetchAllDishes();
    _cachedDishes = rawData.map((e) => DishModel.fromJson(e)).toList();
    print("✅ Cached ${_cachedDishes!.length} dishes.");
    return _cachedDishes!;
  }

  /// Get a specific dish by ID (from cache if possible)
  Future<DishModel?> getDishById(int dishId) async {
    print("🔎 Looking for dish with id=$dishId");

    // If we already have the dishes, filter locally
    if (_cachedDishes != null && _cachedDishes!.isNotEmpty) {
      final found =
          _cachedDishes!.firstWhere((dish) => dish.id == dishId, orElse: () => DishModelExtensionsEmpty.empty());
      if (found.id != null) {
        print("🎉 Found dish in cache: ${found.name} (id=${found.id})");
        return found;
      } else {
        print("❌ Dish with id=$dishId not found in cache");
        return null;
      }
    }

    // If cache empty, fetch once
    print("⚠️ Cache empty, fetching all dishes...");
    final dishes = await getAllDishes();
    try {
      final found = dishes.firstWhere((dish) => dish.id == dishId);
      print("🎉 Found dish after fetching: ${found.name} (id=${found.id})");
      return found;
    } catch (e) {
      print("❌ Dish with id=$dishId not found even after fetching");
      return null;
    }
  }

  /// Optional: force-refresh dishes
  Future<void> refreshDishes() async {
    print("🔄 Refreshing dishes...");
    final rawData = await service.fetchAllDishes();
    _cachedDishes = rawData.map((e) => DishModel.fromJson(e)).toList();
    print("✅ Refreshed cache (${_cachedDishes!.length})");
  }
}

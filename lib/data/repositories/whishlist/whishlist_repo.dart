import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/whishlist/whishlist_service.dart';

class FavoriteRepository {
  final FavoriteService service;

  FavoriteRepository(this.service);

  // ✅ Fetch favorites
Future<List<DishModel>> getFavorites() async {
  final isGuest = await TokenStorage.isGuest();
  if (isGuest) {
    final storeId = await TokenStorage.getChosenStoreId(); // or your store watcher state

    print("🟨 Fetching favorites from local storage for guest");
    return LocalCartStorage.getFavorites(storeId!);
  }
  print("🟩 Fetching favorites from API for logged-in user");
  return service.getWishlist(); // always call API for logged-in
}


  // ✅ Add to favorites
  Future<bool> addFavorite(DishModel dish) async {
    final isGuest = await TokenStorage.isGuest();
    if (isGuest) {
      final storeId = await TokenStorage.getChosenStoreId();
await LocalCartStorage.addToFavorites(storeId!, dish);
      return true; // convert void to bool
    }

    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token not available");
    return service.toggleFavorite(dishId: dish.id);
  }

  // ✅ Remove from favorites
  Future<bool> removeFavorite(DishModel dish) async {
    final isGuest = await TokenStorage.isGuest();
    if (isGuest) {
      final storeId = await TokenStorage.getChosenStoreId();
      await LocalCartStorage.removeFromFavorites(storeId!, dish.id); // ✅ FIXED
      return true;
    }

    final token = await TokenStorage.getAccessToken();
    if (token == null) throw Exception("Token not available");
    return service.removeFavorite(dishId: dish.id, wishlistId: dish.wishlistId);
  }

  // ✅ Clear favorites
 Future<void> clearFavorites() async {
    final isGuest = await TokenStorage.isGuest();
    if (isGuest) {
      final storeId = await TokenStorage.getChosenStoreId();
      await LocalCartStorage.clearFavorites(storeId!); // ✅ FIXED
    }
  }
}


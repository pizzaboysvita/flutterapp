import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/whishlist/whishlist_service.dart';

class FavoriteRepository {
  final FavoriteService service;

  FavoriteRepository(this.service);

  Future<bool> toggleFavorite({
    required int dishId,
    required String token,
  }) async {
    return await service.toggleFavorite(dishId: dishId);
  }

  // ✅ New method for removeFavorite
  Future<bool> removeFavorite({
    required int dishId,
    int? wishlistId, // ✅ optional parameter
    required String token,
  }) async {
    return await service.removeFavorite(dishId: dishId, wishlistId: wishlistId);
  }

  // ✅ Fetch wishlist
  Future<List<DishModel>> getWishlist() async {
    return await service.getWishlist();
  }
}

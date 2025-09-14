import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/whishlist/whishlist_service.dart';

class FavoriteRepository {
  final FavoriteService service;

  FavoriteRepository(this.service);

  Future<bool> toggleFavorite({
    required int dishId,
    required String token,
  }) async {
    return await service.toggleFavorite(
      dishId: dishId,
      token: token,
    );
  }

    // ✅ New method for fetching wishlist
  Future<List<DishModel>> getWishlist({
    required String token,
  }) async {
    return await service.getWishlist(token: token);
  }
}

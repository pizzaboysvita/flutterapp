import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pizza_boys/data/models/dish/guest_cart_item_model.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

class LocalCartStorage {
  // Key builders
  static String _cartKey(String storeId) => 'guest_cart_$storeId';
  static String _favKey(String storeId) => 'guest_fav_$storeId';

  // ==================== 🛒 CART METHODS ====================

  /// Add item to store-specific cart
  static Future<void> addGuestCartItem(
    String storeId,
    GuestCartItemModel item,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getGuestCartItems(storeId);

    final index = cart.indexWhere((i) => i.dish.id == item.dish.id);
    if (index != -1) {
      final existing = cart[index];
      final updated = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      cart[index] = updated;
    } else {
      cart.add(item);
    }

    await prefs.setString(
      _cartKey(storeId),
      jsonEncode(cart.map((e) => e.toJson()).toList()),
    );
  }

  /// Get all cart items for specific store
  static Future<List<GuestCartItemModel>> getGuestCartItems(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey(storeId));
    if (jsonString == null) return [];

    final List list = jsonDecode(jsonString);
    return list.map((e) => GuestCartItemModel.fromJson(e)).toList();
  }

  /// Remove a cart item by dishId
  static Future<void> removeFromCart(String storeId, int dishId) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getGuestCartItems(storeId);

    cart.removeWhere((i) => i.dish.id == dishId);

    await prefs.setString(
      _cartKey(storeId),
      jsonEncode(cart.map((e) => e.toJson()).toList()),
    );
  }

  /// Clear cart for specific store
  static Future<void> clearCart(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey(storeId));
  }

  // ==================== ❤️ FAVORITES METHODS ====================

  /// Add favorite dish for specific store
  static Future<void> addToFavorites(String storeId, DishModel dish) async {
    final prefs = await SharedPreferences.getInstance();
    final fav = await getFavorites(storeId);

    if (!fav.any((d) => d.id == dish.id)) {
      fav.add(dish);

      await prefs.setString(
        _favKey(storeId),
        jsonEncode(fav.map((d) => d.toJson()).toList()),
      );
    }
  }

  /// Get all favorite dishes for specific store
  static Future<List<DishModel>> getFavorites(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favKey(storeId));
    if (jsonString == null) return [];

    final List list = jsonDecode(jsonString);
    return list.map((e) => DishModel.fromJson(e)).toList();
  }

  /// Remove dish from favorites
  static Future<void> removeFromFavorites(String storeId, int dishId) async {
    final prefs = await SharedPreferences.getInstance();
    final fav = await getFavorites(storeId);

    fav.removeWhere((d) => d.id == dishId);

    await prefs.setString(
      _favKey(storeId),
      jsonEncode(fav.map((d) => d.toJson()).toList()),
    );
  }

  /// Clear favorites for specific store
  static Future<void> clearFavorites(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favKey(storeId));
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

/// A unified local storage helper for both Cart & Favorites.
/// Clean, optimized, and easy to extend (guest mode, offline, etc.)
class LocalCartStorage {
  static const _cartKey = 'guest_cart';
  static const _favKey = 'guest_favorites';

  // ==================== 🛒 CART METHODS ====================

  /// Add a dish to the local cart (avoid duplicates)
  static Future<void> addToCart(DishModel dish) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCartItems();

    if (!cart.any((d) => d.id == dish.id)) {
      cart.add(dish);
      await prefs.setString(
        _cartKey,
        jsonEncode(cart.map((d) => d.toJson()).toList()),
      );
    }
  }

  /// Get all items in the local cart
  static Future<List<DishModel>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey);
    if (jsonString == null) return [];

    final List list = jsonDecode(jsonString);
    return list.map((e) => DishModel.fromJson(e)).toList();
  }

  /// Remove a dish from the local cart
  static Future<void> removeFromCart(int dishId) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCartItems();

    cart.removeWhere((d) => d.id == dishId);

    await prefs.setString(
      _cartKey,
      jsonEncode(cart.map((d) => d.toJson()).toList()),
    );
  }

  /// Clear all items in the local cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // ==================== ❤️ FAVORITES METHODS ====================

  /// Add a dish to local favorites (avoid duplicates)
  static Future<void> addToFavorites(DishModel dish) async {
    final prefs = await SharedPreferences.getInstance();
    final fav = await getFavorites();

    if (!fav.any((d) => d.id == dish.id)) {
      fav.add(dish);
      await prefs.setString(
        _favKey,
        jsonEncode(fav.map((d) => d.toJson()).toList()),
      );
    }
  }

  /// Get all locally saved favorite dishes
  static Future<List<DishModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favKey);
    if (jsonString == null) return [];

    final List list = jsonDecode(jsonString);
    return list.map((e) => DishModel.fromJson(e)).toList();
  }

  /// Remove a dish from favorites
  static Future<void> removeFromFavorites(int dishId) async {
    final prefs = await SharedPreferences.getInstance();
    final fav = await getFavorites();

    fav.removeWhere((d) => d.id == dishId);

    await prefs.setString(
      _favKey,
      jsonEncode(fav.map((d) => d.toJson()).toList()),
    );
  }

  /// Clear all local favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favKey);
  }
}

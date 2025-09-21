import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/data/services/cart/cart_service.dart';

class CartRepository {
  final CartService _cartService;

  CartRepository(this._cartService);

  // Cart Post Repo
  Future<Map<String, dynamic>> addDishToCart({
    required int userId,
    required int dishId,
    required int storeId,
    required int quantity,
    required double price,
    required String optionsJson,
  }) async {
    try {
      final response = await _cartService.addToCart(
        type: "insert",
        userId: userId,
        dishId: dishId,
        storeId: storeId,
        quantity: quantity,
        price: price,
        optionsJson: optionsJson,
      );
      return response;
    } catch (e) {
      throw Exception("CartRepository Error: $e");
    }
  }

  // Cart Get Repo
  Future<List<CartItem>> fetchCart() async {
    return await _cartService.getCartItems();
  }

  // ✅ Cart Remove Repo
  Future<Map<String, dynamic>> removeFromCart({
    required int cartId,
    required int userId,
  }) async {
    try {
      final response = await _cartService.removeFromCart(
        cartId: cartId,
        userId: userId,
      );
      return response;
    } catch (e) {
      throw Exception("CartRepository Error: $e");
    }
  }
}

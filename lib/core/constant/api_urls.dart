import 'package:pizza_boys/core/storage/api_res_storage.dart';

class ApiUrls {
  // Endpoints
  static const String loginPost = "loginUser";
  static const String wishlist = "wishlist";
  static const String postOrders = "order";
  static const String refreshToken = "refreshToken";
  static const String storesGet = "store?type=web";

  // Dynamic URLs
  static Future<String> _getStoreId() async {
    return await TokenStorage.getChosenStoreId() ?? "-1";
  }

  static Future<String> getCategoriesUrl() async {
    final storeId = await _getStoreId();
    return "category?store_id=$storeId&type=web";
  }

  static Future<String> getDishUrl() async {
    final storeId = await _getStoreId();
    return "dish?store_id=$storeId&type=web";
  }

  static Future<String> getRegisterUrl() async {
    final storeId = await _getStoreId();
    return "user?store_id=$storeId&type=web";
  }
}

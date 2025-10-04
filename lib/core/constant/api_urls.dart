import 'package:pizza_boys/core/storage/api_res_storage.dart';

class ApiUrls {
  // Endpoints only, use with ApiClient.dio
  static const String loginPost = "loginUser";
  static const String storesGet = "store?type=web";
  static const String wishlist = "wishlist";
  static const String postOrders = "order";
  static const String refreshToken = "refreshToken";

  /// Returns categories URL with dynamic storeId (fallback to -1 if null)
  static Future<String> getCategoriesUrl() async {
    final storeIdStr = await TokenStorage.getChosenStoreId();
    final storeId = storeIdStr ?? "-1";
    return "category?store_id=$storeId&type=web";
  }

  /// Returns dishes URL with dynamic storeId (fallback to -1 if null)
  static Future<String> getDishUrl() async {
    final storeIdStr = await TokenStorage.getChosenStoreId();
    final storeId = storeIdStr ?? "-1";
    return "dish?store_id=$storeId&type=web";
  }

  /// Returns register URL with dynamic storeId (fallback to -1 if null)
  static Future<String> getRegisterUrl() async {
    final storeIdStr = await TokenStorage.getChosenStoreId();
    final storeId = storeIdStr ?? "-1";
    return "user?store_id=$storeId&type=web";
  }
}

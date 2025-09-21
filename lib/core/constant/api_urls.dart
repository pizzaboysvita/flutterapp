class ApiUrls {
  // Endpoints only, use with ApiClient.dio
  static const String getCategories = "category?store_id=-1&type=web";
  static const String getDish = "dish?store_id=-1&type=web";
  static const String register = 'user?store_id=-1&type=web';
  static const String loginPost = "loginUser";
  static const String storesGet = "store?type=web";
  static const String wishlist = "wishlist";
  static const String postOrders = "order";
  static const String refreshToken = "refreshToken";
}

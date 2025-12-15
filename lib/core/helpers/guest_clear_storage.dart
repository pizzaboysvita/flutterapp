import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';

class GuestCleanupHelper {
  static Future<void> clearGuestData() async {
    final storeId = await TokenStorage.getChosenStoreId();

    if (storeId != null) {
      await LocalCartStorage.clearCart(storeId);
      await LocalCartStorage.clearFavorites(storeId);
    }

    await TokenStorage.clearSession();
  }
}

import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/services/auth/login_service.dart';

class LoginRepo {
  final LoginService _service = LoginService();

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final data = await _service.postLogin(email, password);

    return data;
  }

  // ✅ Guest Login – no API
  Future<void> guestLogin() async {
    print("👤 [LoginRepo] Starting guest session setup (no API)...");

    await TokenStorage.saveGuestSession("guest_session_token");

   final storeId = await TokenStorage.getChosenStoreId(); // or your store watcher state

await LocalCartStorage.clearCart(storeId!);
await LocalCartStorage.clearFavorites(storeId!);

    print("✅ [LoginRepo] Guest session initialized locally.");
  }
}

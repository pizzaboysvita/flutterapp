
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
  // ✅ Guest Login – local only
  Future<void> guestLogin() async {
    print("👤 [LoginRepo] Starting guest session setup (no API)...");

    // Save guest flag + guest token using your existing method
    await TokenStorage.saveGuestSession("guest_session_token");

    // Clear local data to start fresh
    await LocalCartStorage.clearCart();
    await LocalCartStorage.clearFavorites();

    print("✅ [LoginRepo] Guest session initialized locally.");
  }
}

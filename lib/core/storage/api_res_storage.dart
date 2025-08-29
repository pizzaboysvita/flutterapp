import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userRefreshTokenKey = 'user_refresh_token';
  static const _userIdKey = 'user_id';
  static const _roleIdKey = 'role_id';
  static const _emailKey = 'email';
  static const _nameKey = 'name';
  static const _profileKey = 'profile';
  static const _permissionsKey = 'permissions';
  static const _chosenLocationKey = 'chosen_location';
  static const _chosenStoreIdKey = 'chosen_store_id';

  // Save all user session data
  static Future<void> saveSession(Map<String, dynamic> data) async {
    print("🔐 [TokenStorage] Saving session data...");

    await _storage.write(key: _accessTokenKey, value: data["access_token"]);
    await _storage.write(key: _refreshTokenKey, value: data["refresh_token"]);

    final user = data["user"];
    await _storage.write(
      key: _userRefreshTokenKey,
      value: user["refresh_token"],
    );
    await _storage.write(key: _userIdKey, value: user["user_id"].toString());
    await _storage.write(key: _roleIdKey, value: user["role_id"].toString());
    await _storage.write(key: _emailKey, value: user["email"]);

    final fullName = "${user["first_name"]} ${user["last_name"]}";
    await _storage.write(key: _nameKey, value: fullName);

    await _storage.write(key: _profileKey, value: user["profiles"]);
    await _storage.write(key: _permissionsKey, value: user["permissions"]);

    print("🎉 [TokenStorage] Session data saved successfully.");
  }

  // Getters
  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessTokenKey);

  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshTokenKey);

  static Future<String?> getUserRefreshToken() async =>
      await _storage.read(key: _userRefreshTokenKey);

  static Future<String?> getUserId() async =>
      await _storage.read(key: _userIdKey);

  static Future<String?> getRoleId() async =>
      await _storage.read(key: _roleIdKey);

  static Future<String?> getEmail() async =>
      await _storage.read(key: _emailKey);

  static Future<String?> getName() async => await _storage.read(key: _nameKey);

  static Future<String?> getProfile() async =>
      await _storage.read(key: _profileKey);

  static Future<String?> getPermissions() async =>
      await _storage.read(key: _permissionsKey);

  /// Save chosen location (store_id + name/anything)
  static Future<void> saveChosenLocation({
    required String storeId,
    required String locationName,
  }) async {
    await _storage.write(key: _chosenLocationKey, value: locationName);
    await _storage.write(key: _chosenStoreIdKey, value: storeId);
    print("📍 [TokenStorage] Saved chosen location: $locationName ($storeId)");
  }

  static Future<String?> getChosenLocation() async =>
      await _storage.read(key: _chosenLocationKey);

  static Future<String?> getChosenStoreId() async =>
      await _storage.read(key: _chosenStoreIdKey);

  // Clear session on logout
  static Future<void> clearSession() async {
    await _storage.deleteAll();
    print("🗑️ [TokenStorage] All session data cleared.");
  }
}

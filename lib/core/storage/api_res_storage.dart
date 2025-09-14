import 'package:flutter/services.dart';
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

    try {
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
    } catch (e) {
      print("⚠️ [TokenStorage] Error saving session data: $e");
    }
  }

  // Centralized error handling for reading keys
  static Future<String?> _readKey(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      print("⚠️ [TokenStorage] PlatformException reading $key: ${e.message}");
      if (e.message?.contains("BAD_DECRYPT") == true) {
        print("⚠️ [TokenStorage] Detected BAD_DECRYPT, clearing session.");
        await clearSession();
      }
      return null;
    } catch (e) {
      print("⚠️ [TokenStorage] Unknown error reading $key: $e");
      return null;
    }
  }

  // Getters with centralized error handling
  static Future<String?> getAccessToken() async => await _readKey(_accessTokenKey);
  static Future<String?> getRefreshToken() async => await _readKey(_refreshTokenKey);
  static Future<String?> getUserRefreshToken() async => await _readKey(_userRefreshTokenKey);
  static Future<String?> getUserId() async => await _readKey(_userIdKey);
  static Future<String?> getRoleId() async => await _readKey(_roleIdKey);
  static Future<String?> getEmail() async => await _readKey(_emailKey);
  static Future<String?> getName() async => await _readKey(_nameKey);
  static Future<String?> getProfile() async => await _readKey(_profileKey);
  static Future<String?> getPermissions() async => await _readKey(_permissionsKey);
  static Future<String?> getChosenLocation() async => await _readKey(_chosenLocationKey);
  static Future<String?> getChosenStoreId() async => await _readKey(_chosenStoreIdKey);

  // Save chosen location (store_id + name/anything)
  static Future<void> saveChosenLocation({
    required String storeId,
    required String locationName,
  }) async {
    try {
      await _storage.write(key: _chosenLocationKey, value: locationName);
      await _storage.write(key: _chosenStoreIdKey, value: storeId);
      print("📍 [TokenStorage] Saved chosen location: $locationName ($storeId)");
    } catch (e) {
      print("⚠️ [TokenStorage] Error saving chosen location: $e");
    }
  }

  // Clear session on logout or when BAD_DECRYPT occurs
  static Future<void> clearSession() async {
    try {
      await _storage.deleteAll();
      print("🗑️ [TokenStorage] All session data cleared.");
    } catch (e) {
      print("⚠️ [TokenStorage] Error clearing session: $e");
    }
  }
}

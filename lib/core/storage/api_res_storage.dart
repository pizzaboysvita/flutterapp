import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _roleIdKey = 'role_id';
  static const _emailKey = 'email';
  static const _nameKey = 'name';
  static const _profileKey = 'profile';
  static const _permissionsKey = 'permissions';
  static const _chosenLocationKey = 'chosen_location';
  static const _chosenStoreIdKey = 'chosen_store_id';
  static const _storeNameKey = 'store_name';

  // Save all user session data (access + refresh + profile)
  static Future<void> saveSession(Map<String, dynamic> data) async {
    print("🔐 [TokenStorage] Saving session data...");

    try {
      // Always overwrite tokens with latest
      final accessToken = data["access_token"];
      final refreshToken = data["refresh_token"];

      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);

      final user = data["user"];
      if (user != null) {
        await _storage.write(
          key: _userIdKey,
          value: user["user_id"].toString(),
        );
        await _storage.write(
          key: _roleIdKey,
          value: user["role_id"].toString(),
        );
        await _storage.write(key: _emailKey, value: user["email"]);

        final fullName =
            "${user["first_name"] ?? ""} ${user["last_name"] ?? ""}".trim();
        await _storage.write(key: _nameKey, value: fullName);

        await _storage.write(key: _profileKey, value: user["profiles"]);
        await _storage.write(key: _permissionsKey, value: user["permissions"]);
      }

      print(
        "🎉 [TokenStorage] Session saved → Access + Refresh tokens updated",
      );
    } catch (e) {
      print("⚠️ [TokenStorage] Error saving session: $e");
    }
  }

  // Centralized safe read
  static Future<String?> _readKey(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      print("⚠️ [TokenStorage] PlatformException reading $key: ${e.message}");
      if (e.message?.contains("BAD_DECRYPT") == true) {
        await clearSession();
      }
      return null;
    } catch (e) {
      print("⚠️ [TokenStorage] Unknown error reading $key: $e");
      return null;
    }
  }

  // user flow existing/new user
// user flow existing/new user
static const String _isFirstLaunchKey = "is_first_launch";

static Future<bool> getIsFirstLaunch() async {
  try {
    final value = await _storage.read(key: _isFirstLaunchKey);
    if (value == null) return true; // treat null as first launch
    return value == "true";
  } catch (e) {
    print("⚠️ [TokenStorage] Error reading isFirstLaunch: $e");
    return true;
  }
}

static Future<void> setIsFirstLaunch(bool value) async {
  try {
    await _storage.write(key: _isFirstLaunchKey, value: value.toString());
  } catch (e) {
    print("⚠️ [TokenStorage] Error writing isFirstLaunch: $e");
  }
}

// location chosen flag
static const String _locationChosenKey = "location_chosen";

static Future<bool> isLocationChosen() async {
  try {
    final value = await _storage.read(key: _locationChosenKey);
    if (value == null) return false;
    return value == "true";
  } catch (e) {
    print("⚠️ [TokenStorage] Error reading locationChosen: $e");
    return false;
  }
}

static Future<void> setLocationChosen(bool value) async {
  try {
    await _storage.write(key: _locationChosenKey, value: value.toString());
  } catch (e) {
    print("⚠️ [TokenStorage] Error writing locationChosen: $e");
  }
}




  // Getters
  static Future<String?> getAccessToken() async => _readKey(_accessTokenKey);
  static Future<String?> getRefreshToken() async => _readKey(_refreshTokenKey);
  static Future<String?> getUserId() async => _readKey(_userIdKey);
  static Future<String?> getRoleId() async => _readKey(_roleIdKey);
  static Future<String?> getEmail() async => _readKey(_emailKey);
  static Future<String?> getName() async => _readKey(_nameKey);
  static Future<String?> getProfile() async => _readKey(_profileKey);
  static Future<String?> getPermissions() async => _readKey(_permissionsKey);
  static Future<String?> getChosenLocation() async =>
      _readKey(_chosenLocationKey);
  static Future<String?> getChosenStoreId() async =>
      _readKey(_chosenStoreIdKey);

  // Save chosen location (store_id + name)
  static Future<void> saveChosenLocation({
    required String storeId,
    required String locationName,
  }) async {
    try {
      await _storage.write(key: _chosenLocationKey, value: locationName);
      await _storage.write(key: _chosenStoreIdKey, value: storeId);
      print(
        "📍 [TokenStorage] Saved chosen location: $locationName ($storeId)",
      );
    } catch (e) {
      print("⚠️ [TokenStorage] Error saving chosen location: $e");
    }
  }

  // Save selected store by name only
  static Future<void> saveSelectedStore(Store store) async {
    try {
      await _storage.write(key: _storeNameKey, value: store.name);
      // print("📦 [TokenStorage] Selected store name saved: ${store.name}");
    } catch (e) {
      print("⚠️ [TokenStorage] Error saving selected store name: $e");
    }
  }

  // Load selected store
  static Future<String?> loadSelectedStoreName() async {
    try {
      final name = await _storage.read(key: _storeNameKey);
      if (name != null) {
        // print("📦 [TokenStorage] Loaded store: $name");
      }
      return name;
    } catch (e) {
      print("⚠️ [TokenStorage] Error loading store name: $e");
      return null;
    }
  }

  // Clear session
  static Future<void> clearSession() async {
    try {
      await _storage.deleteAll();
      print("🗑️ [TokenStorage] Session cleared");
    } catch (e) {
      print("⚠️ [TokenStorage] Error clearing session: $e");
    }
  }
}

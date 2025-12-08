// ignore_for_file: empty_catches

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // 🔑 Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _guestAccessTokenKey = 'guest_access_token';
  static const _isGuestKey = 'is_guest';
  static const _userIdKey = 'user_id';
  static const _roleIdKey = 'role_id';
  static const _emailKey = 'email';
  static const _nameKey = 'name';
  static const _profileKey = 'profile';
  static const _permissionsKey = 'permissions';
  static const _chosenLocationKey = 'chosen_location';
  static const _chosenStoreIdKey = 'chosen_store_id';
  static const _storeNameKey = 'store_name';
  static const _popularDishIdsKey = "popular_dish_ids";


  // 🟢 Save user session (normal login)
  static Future<void> saveSession(Map<String, dynamic> data) async {
    try {
      await _storage.write(key: _isGuestKey, value: 'false');

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

      print("🎉 [TokenStorage] User session saved");
    } catch (e) {
      print("❌ [TokenStorage] saveSession failed: $e");
    }
  }

  // 🟣 Save guest session (only access token)
  static Future<void> saveGuestSession(String guestAccessToken) async {
    try {
      await _storage.write(key: _isGuestKey, value: 'true');
      await _storage.write(key: _guestAccessTokenKey, value: guestAccessToken);
      print("👤 [TokenStorage] Guest session saved");
    } catch (e) {
      print("❌ [TokenStorage] saveGuestSession failed: $e");
    }
  }

  // 🧠 Helper to detect current session type
  static Future<bool> isGuest() async {
    final value = await _storage.read(key: _isGuestKey);
    return value == 'true';
  }

  // 🧾 Getters (auto-handle guest vs user)
  static Future<String?> getAccessToken() async {
    final guest = await isGuest();
    return guest ? _readKey(_guestAccessTokenKey) : _readKey(_accessTokenKey);
  }

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

  // ✅ Save chosen location (store_id + name)
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
      print("❌ [TokenStorage] saveChosenLocation failed: $e");
    }
  }

  // ✅ Save selected store
  static Future<void> saveSelectedStore(Store store) async {
    try {
      await _storage.write(key: _storeNameKey, value: store.name);
    } catch (e) {}
  }

  static Future<String?> loadSelectedStoreName() async {
    try {
      return await _storage.read(key: _storeNameKey);
    } catch (e) {
      return null;
    }
  }

  // 🚀 First Launch Tracking
  static const String _isFirstLaunchKey = "is_first_launch";

  static Future<bool> getIsFirstLaunch() async {
    try {
      final value = await _storage.read(key: _isFirstLaunchKey);
      return value == null ? true : value == "true";
    } catch (e) {
      return true;
    }
  }

  static Future<void> setIsFirstLaunch(bool value) async {
    await _storage.write(key: _isFirstLaunchKey, value: value.toString());
  }

  // 📍 Location chosen flag
  static const String _locationChosenKey = "location_chosen";

  static Future<bool> isLocationChosen() async {
    final value = await _storage.read(key: _locationChosenKey);
    return value == "true";
  }

  static Future<void> setLocationChosen(bool value) async {
    await _storage.write(key: _locationChosenKey, value: value.toString());
  }

  // 🧹 Clear all sessions (user + guest)
  static Future<void> clearSession() async {
    try {
      // Step 1: Preserve important store-related keys
      final storeId = await _storage.read(key: _chosenStoreIdKey);
      final storeName = await _storage.read(key: _storeNameKey);
      final locationName = await _storage.read(key: _chosenLocationKey);

      // Step 2: Clear only session-related keys
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _guestAccessTokenKey);
      await _storage.delete(key: _isGuestKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _roleIdKey);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _nameKey);
      await _storage.delete(key: _profileKey);
      await _storage.delete(key: _permissionsKey);

      // Step 3: Restore the saved store info
      if (storeId != null) {
        await _storage.write(key: _chosenStoreIdKey, value: storeId);
      }
      if (storeName != null) {
        await _storage.write(key: _storeNameKey, value: storeName);
      }
      if (locationName != null) {
        await _storage.write(key: _chosenLocationKey, value: locationName);
      }

      print("🧽 [TokenStorage] Session cleared but store info preserved");
    } catch (e) {
      print("❌ [TokenStorage] clearSession failed: $e");
    }
  }

  // 🧩 Private helper
  static Future<String?> _readKey(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      if (e.message?.contains("BAD_DECRYPT") == true) {
        await clearSession();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ============================
//  POPULAR PICKS STORAGE
// ============================

static Future<void> savePopularDishIds(List<int> ids) async {
  try {
    final value = ids.join(",");

    await _storage.write(
      key: _popularDishIdsKey,
      value: value,
    );

    print("✅ [TokenStorage] Saved Popular Picks IDs: $value");
  } catch (e) {
    print("❌ [TokenStorage] savePopularDishIds failed: $e");
  }
}

static Future<List<int>> loadPopularDishIds() async {
  try {
    final value = await _storage.read(key: _popularDishIdsKey);

    if (value == null || value.isEmpty) return [];

    final ids = value
        .split(",")
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();

    print("✅ [TokenStorage] Loaded Popular Picks IDs: $ids");

    return ids;
  } catch (e) {
    print("❌ [TokenStorage] loadPopularDishIds failed: $e");
    return [];
  }
}

}

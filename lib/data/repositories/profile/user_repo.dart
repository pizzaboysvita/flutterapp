import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/services/profile/user_service.dart';
import 'package:http_parser/http_parser.dart';


class UserRepo {
  final UserService service;
  UserRepo(this.service);

  Future<Response> deleteUserAccount() async {
    final userId = await TokenStorage.getUserId();

    debugPrint("🧑 USER ID: $userId");

    if (userId == null || userId.isEmpty) {
      debugPrint("❌ User ID not found");
      throw Exception("User ID not found");
    }

    final endpoint = "user/$userId";
    debugPrint("🚀 DELETE API → $endpoint");

    try {
      final response = await ApiClient.dio.delete(endpoint);

      debugPrint("✅ STATUS CODE: ${response.statusCode}");
      debugPrint("📦 RESPONSE DATA: ${response.data}");

      return response;
    } on DioException catch (e) {
      debugPrint("❌ API ERROR");
      debugPrint("STATUS: ${e.response?.statusCode}");
      debugPrint("DATA: ${e.response?.data}");
      debugPrint("MESSAGE: ${e.message}");

      rethrow;
    }
  }

Future<Response> updateUser({
  Map<String, dynamic>? updatedFields,
  File? imageFile,
}) async {
  try {
    print("━━━━━━━━ UPDATE USER API START ━━━━━━━━");

    final userId = await TokenStorage.getUserId();
    if (userId == null) throw Exception("User ID missing");

    final roleId = await TokenStorage.getRoleId();
    final email = await TokenStorage.getEmail();
    final name = await TokenStorage.getName();
    final existingProfile = await TokenStorage.getProfile();
    final refreshToken = await TokenStorage.getRefreshToken();
    final storeId = await TokenStorage.getChosenStoreId();
    final permissions = await TokenStorage.getPermissions();

    /// Stored optional fields
    final phoneNumber = await TokenStorage.getValue("phone_number");
    final passwordHash = await TokenStorage.getValue("password_hash");
    final address = await TokenStorage.getValue("address");
    final country = await TokenStorage.getValue("country");
    final state = await TokenStorage.getValue("state");
    final city = await TokenStorage.getValue("city");
    final posPin = await TokenStorage.getValue("pos_pin");

    /// Debug stored values
    print("📦 TOKEN STORED VALUES:");
    print("phone_number => $phoneNumber");
    print("password_hash => $passwordHash");
    print("address => $address");
    print("country => $country");
    print("state => $state");
    print("city => $city");
    print("pos_pin => $posPin");

    final splitName = (name ?? "").split(" ");

    final firstName =
        updatedFields?["first_name"] ??
        (splitName.isNotEmpty ? splitName.first : "");

    final lastName =
        updatedFields?["last_name"] ??
        (splitName.length > 1 ? splitName.sublist(1).join(" ") : "");

    /// ⭐ PROFILE LOGIC
    final profileToSend =
        imageFile != null ? imageFile.path : existingProfile;

    /// ⭐ BUILD BODY DYNAMICALLY
    Map<String, dynamic> body = {
      "type": "update",
      "user_id": userId,
      "role_id": roleId,
      "store_id": storeId,
      "first_name": firstName,
      "last_name": lastName,
      "email": updatedFields?["email"] ?? email ?? "",
      "profiles": profileToSend,
      "created_by": userId,
      "updated_by": userId,
      "refresh_token": refreshToken,
      "permissions": permissions ?? {},
    };

    /// ⭐ OPTIONAL FIELDS → ADD ONLY IF VALUE EXISTS
    void addIfValid(String key, dynamic value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        body[key] = value;
      }
    }

    addIfValid(
        "phone_number", updatedFields?["phone_number"] ?? phoneNumber);
    addIfValid(
        "password_hash", updatedFields?["password_hash"] ?? passwordHash);
    addIfValid("address", updatedFields?["address"] ?? address);
    addIfValid("country", updatedFields?["country"] ?? country);
    addIfValid("state", updatedFields?["state"] ?? state);
    addIfValid("city", updatedFields?["city"] ?? city);
    addIfValid("pos_pin", updatedFields?["pos_pin"] ?? posPin);

    /// ✅ PRINT BODY
    print("📤 FINAL JSON BODY:");
    print(jsonEncode(body));

    /// IMAGE DEBUG
    if (imageFile != null) {
      print("🖼 Image Selected:");
      print("Path => ${imageFile.path}");
      print("Name => ${imageFile.path.split('/').last}");
      print("Size => ${await imageFile.length()} bytes");
    } else {
      print("🖼 No Image Selected");
    }

    /// ⭐ FORMDATA
    FormData formData = FormData.fromMap({
      "body": jsonEncode(body),
      if (imageFile != null)
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: _getMediaType(imageFile),
        ),
    });

    /// DEBUG FORMDATA
    print("📦 FormData Fields:");
    formData.fields.forEach((field) {
      print("${field.key} => ${field.value}");
    });

    print("📦 FormData Files:");
    formData.files.forEach((file) {
      print("${file.key} => ${file.value.filename}");
    });

    print("🚀 CALLING UPDATE USER API...");

    final response = await service.updateUser(formData);

    print("━━━━━━━━ RESPONSE RECEIVED ━━━━━━━━");
    print("Status Code => ${response.statusCode}");
    print("Response => ${response.data}");
    print("━━━━━━━━ END RESPONSE ━━━━━━━━");

    final data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    /// SAVE LOCALLY
    if (data["code"] == 1) {
      await TokenStorage.saveUpdatedUserDetails(
        firstName: firstName,
        lastName: lastName,
        email: body["email"],
        profile: profileToSend,
      );

      print("✅ Local storage updated");
    }

    print("━━━━━━━━ UPDATE USER API END ━━━━━━━━");

    return response;
  } catch (e) {
    print("🔥 UPDATE USER ERROR => $e");
    rethrow;
  }
}



  MediaType _getMediaType(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    switch (ext) {
      case "jpg":
      case "jpeg":
        return MediaType("image", "jpeg");
      case "png":
        return MediaType("image", "png");
      case "svg":
        return MediaType("image", "svg+xml");
      default:
        throw Exception("Unsupported file type: $ext");
    }
  }




}

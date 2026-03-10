import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/core/helpers/error_handling_helper.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

class AuthService {
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String address,
    required String country,
    required String state,
    required String city,
    required int pinCode,
    File? imageFile,
  }) async {
    try {
      print("━━━━━━━━ REGISTER USER API START ━━━━━━━━");

      final storeIdStr = await TokenStorage.getChosenStoreId();

      print("🟦 Store ID From TokenStorage => $storeIdStr");

      if (storeIdStr == null) {
        print("❌ Store ID is NULL");
        throw Exception("Store ID not available.");
      }

      final Map<String, dynamic> body = {
        "type": "insert",
        "role_id": 1,
        "store_id": int.parse(storeIdStr),
        "first_name": firstName,
        "last_name": lastName,
        "phone_number": phone,
        "email": email,
        "password_hash": password,
        "address": address,
        "country": country,
        "state": state,
        "city": city,
        "pos_pin": pinCode,
        "status": 1,
        "created_by": 1,
        "updated_by": 1,
        "refresh_token": "",
        "permissions": {
          "create": false,
          "dashboard": true,
          "orders_board_view": false,
          "orders_list_view": false,
          "orders_delete": true,
          "bookings": true,
          "bookings_delete": true,
          "customers": false,
          "menus": false,
          "menus_images": false,
          "settings_systems": false,
          "settings_services": false,
          "settings_payments": false,
          "settings_website": false,
          "settings_integrations": false,
          "billing": false,
          "reports": false,
        },
      };

      /// ✅ PRINT COMPLETE BODY
      print("📤 Sending JSON Body:");
      print(jsonEncode(body));

      /// ✅ IMAGE DEBUG
      if (imageFile != null) {
        print("🖼 Image Selected:");
        print("   Path => ${imageFile.path}");
        print("   Name => ${imageFile.path.split('/').last}");
        print("   Size => ${await imageFile.length()} bytes");
      } else {
        print("🖼 No Image Selected");
      }

      FormData formData = FormData.fromMap({
        "body": jsonEncode(body),
        if (imageFile != null)
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: _getMediaType(imageFile),
          ),
      });

      /// ✅ PRINT FORMDATA FIELDS
      print("📦 FormData Fields:");
      formData.fields.forEach((field) {
        print("   ${field.key} => ${field.value}");
      });

      print("📦 FormData Files:");
      formData.files.forEach((file) {
        print("   ${file.key} => ${file.value.filename}");
      });

      final registerUrl = await ApiUrls.getRegisterUrl();

      print("🌍 Register URL => $registerUrl");

      final response = await ApiClient.dio.post(
        registerUrl,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      /// ✅ FULL RESPONSE DEBUG
      print("━━━━━━━━ RESPONSE RECEIVED ━━━━━━━━");
      print("📥 Status Code => ${response.statusCode}");
      print("📥 Headers => ${response.headers}");
      print("📥 Response Data => ${response.data}");
      print("━━━━━━━━ END RESPONSE ━━━━━━━━");

      /// 🔎 DUPLICATE CHECK
      if (response.data.toString().contains("already exists") ||
          response.data.toString().contains("exists") ||
          response.statusCode == 409) {
        print("⚠️ Duplicate User Found");
        return {"status": false, "message": "User already exists"};
      }

      if (response.statusCode == 200) {
        print("✅ Registration SUCCESS");
        return response.data;
      } else {
        print("❌ Server Error Returned");
        throw Exception(
          ApiErrorHandler.handle(
            DioException(
              requestOptions: RequestOptions(path: registerUrl),
              response: response,
            ),
          ),
        );
      }
    } on DioException catch (e) {
      print("🔥 DioException CAUGHT");
      print("Status => ${e.response?.statusCode}");
      print("Headers => ${e.response?.headers}");
      print("Data => ${e.response?.data}");
      print("Message => ${e.message}");

      throw ApiErrorHandler.handle(e);
    } catch (e) {
      print("🔥 GENERAL EXCEPTION => $e");
      throw ApiErrorHandler.handle(e);
    } finally {
      print("━━━━━━━━ REGISTER USER API END ━━━━━━━━");
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

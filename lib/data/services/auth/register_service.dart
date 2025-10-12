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
      final storeIdStr = await TokenStorage.getChosenStoreId();

      if (storeIdStr == null) {
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

      FormData formData = FormData.fromMap({
        "body": jsonEncode(body),
        if (imageFile != null)
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: _getMediaType(imageFile),
          ),
      });

      final registerUrl = await ApiUrls.getRegisterUrl();

      final response = await ApiClient.dio.post(
        registerUrl,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
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
      throw ApiErrorHandler.handle(e);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
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

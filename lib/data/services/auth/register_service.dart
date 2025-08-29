import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl =
      "http://78.142.47.247:3003/api/user?store_id=-1&type=web";

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
      print("📌 Starting registerUser()...");

      var uri = Uri.parse(baseUrl);
      var request = http.MultipartRequest("POST", uri);
      print("✅ Created MultipartRequest with URL: $baseUrl");

      // ✅ JSON body (like Postman)
      final Map<String, dynamic> body = {
        "type": "insert",
        "role_id": 1,
        "store_id": 4,
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

      // 🔑 send JSON inside "body" field (not individual request.fields)
      request.fields["body"] = jsonEncode(body);

      // ✅ Image upload with correct MIME type
      if (imageFile != null) {
        final ext = imageFile.path.split('.').last.toLowerCase();
        MediaType contentType;
        if (ext == "jpg" || ext == "jpeg") {
          contentType = MediaType("image", "jpeg");
        } else if (ext == "png") {
          contentType = MediaType("image", "png");
        } else if (ext == "svg") {
          contentType = MediaType("image", "svg+xml");
        } else {
          throw Exception("❌ Unsupported file type: $ext");
        }

        print(
          "🖼️ Adding image file: ${imageFile.path} with contentType: $contentType",
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            "image", // 👈 backend expects this field name
            imageFile.path,
            contentType: contentType,
          ),
        );
      } else {
        print("⚠️ No image file provided");
      }

      print("📝 Request fields: ${request.fields}");

      // Send request
      print("📤 Sending request...");
      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      print("📥 Response received with status: ${response.statusCode}");
      print("🔍 Response body: $resBody");

      if (response.statusCode == 200) {
        print("✅ Registration successful!");
        return jsonDecode(resBody);
      } else {
        throw Exception("❌ Failed: $resBody");
      }
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      throw Exception("⚠️ Register Error: $e");
    }
  }
}

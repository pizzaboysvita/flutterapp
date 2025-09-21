import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import 'package:pizza_boys/data/models/category/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      print("📌 Fetching categories...");

      final response = await ApiClient.dio.get(
        ApiUrls.getCategories,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("📥 Response status: ${response.statusCode}");
      print("🔍 Response body: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // Run parsing in background isolate
        return compute(_parseCategories, jsonEncode(data));
      } else {
        throw Exception("Failed to fetch categories: ${response.data}");
      }
    } on DioException catch (e) {
      print("⚠️ DioException while fetching categories: ${e.message}");
      throw Exception("Failed to fetch categories: ${e.message}");
    } catch (e) {
      print("⚠️ Unknown error while fetching categories: $e");
      throw Exception("Failed to fetch categories: $e");
    }
  }

  // Background isolate parser
  List<CategoryModel> _parseCategories(String responseBody) {
    final body = jsonDecode(responseBody);

    if (body['code'] == "1") {
      final categories = List<CategoryModel>.from(
        body['categories'].map((json) => CategoryModel.fromJson(json)),
      );
      return categories;
    } else {
      throw Exception(body['message']);
    }
  }
}

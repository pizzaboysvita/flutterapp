import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/data/models/category/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> fetchCategories() async {
    final url = Uri.parse(ApiUrls.getCategories);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return compute(_parseCategories, response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

List<CategoryModel> _parseCategories(String responseBody) {
  final body = jsonDecode(responseBody);
  if (body['code'] == "1") {
    return List<CategoryModel>.from(
      body['categories'].map((json) => CategoryModel.fromJson(json)),
    );
  } else {
    throw Exception(body['message']);
  }
}

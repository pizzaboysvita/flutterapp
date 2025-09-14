import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/data/models/category/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> fetchCategories() async {
    final url = Uri.parse(ApiUrls.getCategories);
    print("CategoryService: Fetching categories from ${url.toString()}"); 

    final response = await http.get(url);
    print("CategoryService: Response code = ${response.statusCode}"); 
    print("CategoryService: Response body = ${response.body}"); 

    if (response.statusCode == 200) {
      return compute(_parseCategories, response.body);
    } else {
      print("CategoryService: Failed to fetch categories");
      throw Exception('Failed to load categories');
    }
  }
}


List<CategoryModel> _parseCategories(String responseBody) {
  print("CategoryService: Parsing categories");
  final body = jsonDecode(responseBody);
  print("CategoryService: Parsed body = $body"); 

  if (body['code'] == "1") {
    final categories = List<CategoryModel>.from(
      body['categories'].map((json) => CategoryModel.fromJson(json)),
    );
    print("CategoryService: Parsed ${categories.length} categories"); 
    return categories;
  } else {
    print("CategoryService: Error in response - ${body['message']}");
    throw Exception(body['message']);
  }
}


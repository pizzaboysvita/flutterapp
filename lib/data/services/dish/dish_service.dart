import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';

class DishService {
  Future<List<dynamic>> fetchAllDishes() async {
    final response = await http.get(Uri.parse(ApiUrls.getDish));

    if (response.statusCode == 200) {
      return compute(_parseDishes, response.body);
    } else {
      throw Exception("Failed to load dishes");
    }
  }
}

List<dynamic> _parseDishes(String responseBody) {
  final parsed = jsonDecode(responseBody);
  return parsed['data'];
}

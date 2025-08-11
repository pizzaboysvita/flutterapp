import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pizza_boys/core/constant/api_urls.dart';

class DishService {
  Future<List<dynamic>> fetchAllDishes() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getDish),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception("Failed to load dishes");
    }
  }
}

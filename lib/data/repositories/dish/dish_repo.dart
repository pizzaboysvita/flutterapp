

import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';

class DishRepository {
  final DishService service;

  DishRepository(this.service);

  Future<List<DishModel>> getAllDishes() async {
    final rawData = await service.fetchAllDishes();
    print('BAckend Raw Data: $rawData');
    return rawData.map((e) => DishModel.fromJson(e)).toList();
  }
}

import 'package:pizza_boys/data/models/dish/dish_model.dart';

class ComboSide {
  final bool expanded;
  final String name;
  final List<MenuItem> menuItems;

  ComboSide({
    required this.expanded,
    required this.name,
    required this.menuItems,
  });

  factory ComboSide.fromJson(Map<String, dynamic> json) {
    List<MenuItem> parseMenuItems(dynamic jsonData) {
      if (jsonData == null) return [];
      if (jsonData is List) {
        return jsonData.map((e) => MenuItem.fromJson(e)).toList();
      }
      return [];
    }

    return ComboSide(
      expanded: json['expanded'] ?? false,
      name: json['name'] ?? 'Combo',
      menuItems: parseMenuItems(json['menuItems']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expanded': expanded,
      'name': name,
      'menuItems': menuItems.map((e) => e.toJson()).toList(),
    };
  }
}

class MenuItem {
  final bool takeawayExpanded;
  final int menuId;
  final String menuName;
  final List<Category> categories;
  final bool checked;
  final bool indeterminate;

  MenuItem({
    required this.takeawayExpanded,
    required this.menuId,
    required this.menuName,
    required this.categories,
    this.checked = false,
    this.indeterminate = false,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<Category> parseCategories(dynamic jsonData) {
      if (jsonData == null) return [];
      if (jsonData is List) {
        return jsonData.map((e) => Category.fromJson(e)).toList();
      }
      return [];
    }

    return MenuItem(
      takeawayExpanded: json['takeawayExpanded'] ?? false,
      menuId: json['menuId'] ?? 0,
      menuName: json['menuName'] ?? '',
      categories: parseCategories(json['categories']),
      checked: json['checked'] ?? false,
      indeterminate: json['indeterminate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'takeawayExpanded': takeawayExpanded,
      'menuId': menuId,
      'menuName': menuName,
      'categories': categories.map((e) => e.toJson()).toList(),
      'checked': checked,
      'indeterminate': indeterminate,
    };
  }
}

class Category {
  final int categoryId;
  final String categoryName;
  final bool checked;
  final bool expanded;
  final List<DishModel> dishes;
  final bool indeterminate;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.checked,
    required this.expanded,
    required this.dishes,
    this.indeterminate = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<DishModel> parseDishes(dynamic jsonData) {
      if (jsonData == null) return [];
      if (jsonData is List) {
        return jsonData
            .map(
              (e) => DishModel(
                id: e['dishId'] ?? 0,
                name: e['dishName'] ?? '',
                price: 0.0,
                imageUrl: e['image_url'] ?? '',
                rating: 0.0,
                dishCategoryId: json['categoryId'] ?? -1,
                description: '',
                storeId: 0,
                optionSets: [],
                ingredients: [],
                choices: [],
                comboDishes: [],
                comboSides: [],
              ),
            )
            .toList();
      }
      return [];
    }

    return Category(
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      checked: json['checked'] ?? false,
      expanded: json['expanded'] ?? false,
      dishes: parseDishes(json['dishes']),
      indeterminate: json['indeterminate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'checked': checked,
      'expanded': expanded,
      'dishes': dishes.map((e) => e.toJson()).toList(),
      'indeterminate': indeterminate,
    };
  }
}

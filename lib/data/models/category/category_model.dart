class CategoryModel {
  final int id;
  final String name;
  final String categoryImage;

  CategoryModel({
    required this.id,
    required this.name,
    required this.categoryImage,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      categoryImage: json['category_image'],
    );
  }
}

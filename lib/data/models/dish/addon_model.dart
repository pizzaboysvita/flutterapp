class Addon {
  final String name;
  final double price;

  Addon({required this.name, required this.price});

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };
}

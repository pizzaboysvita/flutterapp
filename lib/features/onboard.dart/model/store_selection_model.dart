class Store {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String image;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.image,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['store_id'] as int,
      name: json['store_name'] ?? '',
      address: json['street_address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

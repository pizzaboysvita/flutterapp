class Store {
  final int id;
  final String name;
  final String address; // street address
  final String? city; // optional
  final String? state; // optional
  final String? country; // optional
  final String? zipCode; // optional
  final String phone;
  final String image;

  Store({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    required this.phone,
    required this.image,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['store_id'] as int,
      name: json['store_name'] ?? '',
      address: json['street_address'] ?? '',
      city: json['city'], // optional
      state: json['state'], // optional
      country: json['country'], // optional
      zipCode: json['zip_code'], // optional
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

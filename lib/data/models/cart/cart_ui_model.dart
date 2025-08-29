class CartUIItem {
  final String? imageUrl;
  final String name;
  final double price;
  final int quantity;
  final String? size;
  final String? largeOption;
  final List<String>? addons;
  final List<String>? choices;

  CartUIItem({
    this.imageUrl,
    required this.name,
    required this.price,
    required this.quantity,
    this.size,
    this.largeOption,
    this.addons,
    this.choices,
  });
}

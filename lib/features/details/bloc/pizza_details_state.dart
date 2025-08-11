class PizzaDetailsState {
  final String selectedSize;
  final Map<String, bool> selectedAddons;

  // New fields for Large options
  final String? selectedLargeOption;
  final double largeOptionExtraPrice;

  PizzaDetailsState({
    required this.selectedSize,
    required this.selectedAddons,
    this.selectedLargeOption,
    this.largeOptionExtraPrice = 0,
  });

  factory PizzaDetailsState.initial() {
    return PizzaDetailsState(
      selectedSize: 'Small',
      selectedAddons: {
        'Extra Cheese': false,
        'Coke': false,
        'Garlic Bread': false,
        'French Fries': false,
        'Olives Topping': false,
      },
      selectedLargeOption: null,
      largeOptionExtraPrice: 0,
    );
  }

  PizzaDetailsState copyWith({
    String? selectedSize,
    Map<String, bool>? selectedAddons,
    String? selectedLargeOption,
    double? largeOptionExtraPrice,
  }) {
    return PizzaDetailsState(
      selectedSize: selectedSize ?? this.selectedSize,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      selectedLargeOption: selectedLargeOption ?? this.selectedLargeOption,
      largeOptionExtraPrice: largeOptionExtraPrice ?? this.largeOptionExtraPrice,
    );
  }
}

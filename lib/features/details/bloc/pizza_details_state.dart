import 'package:pizza_boys/data/models/dish/dish_model.dart';

class PizzaDetailsState {
  final bool isLoading;
  final DishModel? dish;
  final String selectedSize;
  final Map<String, bool> selectedAddons;

  final String? selectedLargeOption;
  final double largeOptionExtraPrice;

  /// 👇 Multiple selected choices
  final List<String> selectedChoices;

  /// 👇 Added quantity
  final int quantity;

  /// 👇 New field for addons total price
  final double addonExtraPrice;

  /// 👇 New field for choices total price
  final double choiceExtraPrice;

  final String? error;

  PizzaDetailsState({
    required this.isLoading,
    this.dish,
    required this.selectedSize,
    required this.selectedAddons,
    this.selectedLargeOption,
    this.largeOptionExtraPrice = 0,
    this.selectedChoices = const [],
    this.quantity = 1, // 👈 default 1
    this.addonExtraPrice = 0, // 👈 default 0
    this.choiceExtraPrice = 0, // 👈 default 0
    this.error,
  });

  factory PizzaDetailsState.initial() {
    return PizzaDetailsState(
      isLoading: false,
      dish: null,
      selectedSize: 'Small',
      selectedAddons: {},
      selectedLargeOption: null,
      largeOptionExtraPrice: 0,
      selectedChoices: [],
      quantity: 1,
      addonExtraPrice: 0, // 👈 initial value
      choiceExtraPrice: 0, // 👈 initial value
      error: null,
    );
  }

  PizzaDetailsState copyWith({
    bool? isLoading,
    DishModel? dish,
    String? selectedSize,
    Map<String, bool>? selectedAddons,
    String? selectedLargeOption,
    double? largeOptionExtraPrice,
    List<String>? selectedChoices,
    int? quantity,
    double? addonExtraPrice,
    double? choiceExtraPrice, // 👈 added here
    String? error,
  }) {
    return PizzaDetailsState(
      isLoading: isLoading ?? this.isLoading,
      dish: dish ?? this.dish,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      selectedLargeOption: selectedLargeOption ?? this.selectedLargeOption,
      largeOptionExtraPrice: largeOptionExtraPrice ?? this.largeOptionExtraPrice,
      selectedChoices: selectedChoices ?? this.selectedChoices,
      quantity: quantity ?? this.quantity,
      addonExtraPrice: addonExtraPrice ?? this.addonExtraPrice,
      choiceExtraPrice: choiceExtraPrice ?? this.choiceExtraPrice, // 👈 added here
      error: error ?? this.error,
    );
  }
}

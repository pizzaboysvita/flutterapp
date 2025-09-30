import 'package:pizza_boys/data/models/dish/dish_model.dart';

class PizzaDetailsState {
  final bool isLoading;
  final bool isBaseExpanded;
  final DishModel? dish;

  /// 🍕 Size
  final String selectedSize;

  /// 🍕 Large Option
  final String? selectedLargeOption;
  final double largeOptionExtraPrice;

  /// 🧀 Addons
  final Map<String, bool> selectedAddons;
  final double addonExtraPrice;

  /// 🍕 Base (radio)
  final String? selectedBase;
  final double baseExtraPrice;

  /// 🧀 Toppings
  final Map<String, bool> selectedToppings;
  final double toppingsExtraPrice;

  /// 🥫 Sauces
  final Map<String, int> sauceQuantities;
  final double saucesExtraPrice;

  /// 🥦 Ingredients
  final Map<String, bool> selectedIngredients;

  /// 🍟 Choices
  final Map<String, bool> selectedChoices;
  final double choicesExtraPrice;

  /// 🔢 Quantity
  final int quantity;

  /// ⚠ Error
  final String? error;

  PizzaDetailsState({
    required this.isLoading,
    required this.isBaseExpanded,
    this.dish,
    this.selectedSize = "Small",
    this.selectedLargeOption,
    this.largeOptionExtraPrice = 0,
    this.selectedAddons = const {},
    this.addonExtraPrice = 0,
    this.selectedBase,
    this.baseExtraPrice = 0,
    this.selectedToppings = const {},
    this.toppingsExtraPrice = 0,
    this.sauceQuantities = const {},
    this.saucesExtraPrice = 0,
    this.selectedIngredients = const {},
    this.selectedChoices = const {},
    this.choicesExtraPrice = 0,
    this.quantity = 1,
    this.error,
  });

  factory PizzaDetailsState.initial() => PizzaDetailsState(isLoading: false,  isBaseExpanded: false,);

  PizzaDetailsState copyWith({
    bool? isLoading,
    bool? isBaseExpanded,
    DishModel? dish,
    String? selectedSize,
    String? selectedLargeOption,
    double? largeOptionExtraPrice,
    Map<String, bool>? selectedAddons,
    double? addonExtraPrice,
    String? selectedBase,
    double? baseExtraPrice,
    Map<String, bool>? selectedToppings,
    double? toppingsExtraPrice,
    Map<String, int>? sauceQuantities,
    double? saucesExtraPrice,
    Map<String, bool>? selectedIngredients,
    Map<String, bool>? selectedChoices,
    double? choicesExtraPrice,
    int? quantity,
    String? error, 
  }) {
    return PizzaDetailsState(
      isLoading: isLoading ?? this.isLoading,
       isBaseExpanded: isBaseExpanded ?? this.isBaseExpanded,
      dish: dish ?? this.dish,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedLargeOption: selectedLargeOption ?? this.selectedLargeOption,
      largeOptionExtraPrice: largeOptionExtraPrice ?? this.largeOptionExtraPrice,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      addonExtraPrice: addonExtraPrice ?? this.addonExtraPrice,
      selectedBase: selectedBase ?? this.selectedBase,
      baseExtraPrice: baseExtraPrice ?? this.baseExtraPrice,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      toppingsExtraPrice: toppingsExtraPrice ?? this.toppingsExtraPrice,
      sauceQuantities: sauceQuantities ?? this.sauceQuantities,
      saucesExtraPrice: saucesExtraPrice ?? this.saucesExtraPrice,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      selectedChoices: selectedChoices ?? this.selectedChoices,
      choicesExtraPrice: choicesExtraPrice ?? this.choicesExtraPrice,
      quantity: quantity ?? this.quantity,
      error: error ?? this.error,
    );
  }
}

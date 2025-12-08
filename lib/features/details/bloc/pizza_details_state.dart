import 'package:pizza_boys/data/models/dish/dish_model.dart';

class PizzaDetailsState {
  final bool isLoading;
  final bool isBaseExpanded;
  final DishModel? dish;

  final Map<String, bool> selectedCombo;
  final double comboExtraPrice;

  /// 🍕 Size
  final String selectedSize;

  /// 🍕 Large Option
  final String? selectedLargeOption;
  final double largeOptionExtraPrice;

  /// 🧀 Addons
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

  /// 🥡 Combo Dish
  final DishModel selectedComboDish;

  /// ✅ RADIO OPTIONS
  final Map<String, String> selectedRadioOptions;

  /// ✅ RADIO PRICES TRACKING (NEW)
  final Map<String, double> radioExtraPrices;
  final double radiosExtraPrice;

  PizzaDetailsState({
    required this.isLoading,
    required this.isBaseExpanded,
    this.dish,

    this.selectedSize = "Small",
    this.selectedLargeOption,
    this.largeOptionExtraPrice = 0,

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

    this.selectedCombo = const {},
    this.comboExtraPrice = 0,

    this.quantity = 1,
    this.error,

    required this.selectedComboDish,

    /// ✅ RADIO
    this.selectedRadioOptions = const {},
    this.radioExtraPrices = const {},
    this.radiosExtraPrice = 0,
  });

  factory PizzaDetailsState.initial() => PizzaDetailsState(
        isLoading: false,
        isBaseExpanded: false,
        selectedCombo: const {},
        comboExtraPrice: 0,
        selectedComboDish: DishModelExtensionsEmpty.empty(),
      );

  PizzaDetailsState copyWith({
    bool? isLoading,
    bool? isBaseExpanded,
    DishModel? dish,

    String? selectedSize,
    String? selectedLargeOption,
    double? largeOptionExtraPrice,

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

    Map<String, bool>? selectedCombo,
    double? comboExtraPrice,

    int? quantity,
    String? error,

    DishModel? selectedComboDish,

    Map<String, String>? selectedRadioOptions,

    /// ✅ NEW
    Map<String, double>? radioExtraPrices,
    double? radiosExtraPrice,
  }) {
    return PizzaDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isBaseExpanded: isBaseExpanded ?? this.isBaseExpanded,
      dish: dish ?? this.dish,

      selectedSize: selectedSize ?? this.selectedSize,
      selectedLargeOption: selectedLargeOption ?? this.selectedLargeOption,
      largeOptionExtraPrice:
          largeOptionExtraPrice ?? this.largeOptionExtraPrice,

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

      selectedCombo: selectedCombo ?? this.selectedCombo,
      comboExtraPrice: comboExtraPrice ?? this.comboExtraPrice,

      quantity: quantity ?? this.quantity,
      error: error ?? this.error,

      selectedComboDish: selectedComboDish ?? this.selectedComboDish,

      selectedRadioOptions:
          selectedRadioOptions ?? this.selectedRadioOptions,

      /// ✅ RADIO
      radioExtraPrices: radioExtraPrices ?? this.radioExtraPrices,
      radiosExtraPrice: radiosExtraPrice ?? this.radiosExtraPrice,
    );
  }
}

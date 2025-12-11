// ignore_for_file: override_on_non_overriding_member

import 'package:pizza_boys/data/models/cart/cart_item_model.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';

abstract class PizzaDetailsEvent {}

/// ♻️ Reset everything
class ResetPizzaDetailsEvent extends PizzaDetailsEvent {}

/// 🔄 Load dish details by dishId
class LoadPizzaDetailsEvent extends PizzaDetailsEvent {
  final int dishId;
  LoadPizzaDetailsEvent(this.dishId);
}

class ToggleBaseExpandEvent extends PizzaDetailsEvent {}

// radio option
class SelectOptionSetRadioEvent extends PizzaDetailsEvent {
  final String optionSetName;
  final String selectedOptionName;
  final double extraPrice;

  SelectOptionSetRadioEvent({
    required this.optionSetName,
    required this.selectedOptionName,
    required this.extraPrice,
  });
}


/// 🍕 Select a Base (radio option)
class SelectBaseEvent extends PizzaDetailsEvent {
  final String baseName;
  final double extraPrice;
  SelectBaseEvent(this.baseName, this.extraPrice);
}

/// 🧀 Toggle Topping (checkbox)
class ToggleToppingEvent extends PizzaDetailsEvent {
  final String toppingName;
  final Map<String, double> availableToppings; // name → price
  ToggleToppingEvent(this.toppingName, this.availableToppings);
}

/// 🥫 Update Sauce (stepper with quantity)
class UpdateSauceQuantityEvent extends PizzaDetailsEvent {
  final String sauceName;
  final int quantity;
  final Map<String, double> availableSauces; // name → price
  UpdateSauceQuantityEvent(this.sauceName, this.quantity, this.availableSauces);
}

/// 🥦 Toggle Ingredient (checkbox, optional)
class ToggleIngredientEvent extends PizzaDetailsEvent {
  final String ingredientName;
  ToggleIngredientEvent(this.ingredientName);
}

/// 🍟 Toggle Choice (checkbox, optional side item)
class ToggleChoiceEvent extends PizzaDetailsEvent {
  final String choiceName;
  final Map<String, double> availableChoices; // name → price
  ToggleChoiceEvent(this.choiceName, this.availableChoices);
}

/// 🔢 Update quantity of pizzas
class UpdateQuantityEvent extends PizzaDetailsEvent {
  final int quantity;
  UpdateQuantityEvent(this.quantity);
}

// /for combo
/// 🍱 Toggle Combo Dish
class SelectComboDishEvent extends PizzaDetailsEvent {
  final DishModel comboDish;

  SelectComboDishEvent(this.comboDish);

  @override
  List<Object?> get props => [comboDish];
}

class FetchComboDishDetailsEvent extends PizzaDetailsEvent {
  final int dishId;
  FetchComboDishDetailsEvent(this.dishId);
}

/// 🔁 Restore full pizza config from cart
class RestorePizzaFromCartEvent extends PizzaDetailsEvent {
  final CartItem cartItem;

  RestorePizzaFromCartEvent(this.cartItem);
}


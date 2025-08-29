abstract class PizzaDetailsEvent {}

class ResetPizzaDetailsEvent extends PizzaDetailsEvent {}

// Fetch dish details by id
class LoadPizzaDetailsEvent extends PizzaDetailsEvent {
  final int dishId;
  LoadPizzaDetailsEvent(this.dishId);
}

// Select size
class SelectSizeEvent extends PizzaDetailsEvent {
  final String size;
  SelectSizeEvent(this.size);
}

// Toggle addon
class ToggleAddonEvent extends PizzaDetailsEvent {  
  final String addonName;
  ToggleAddonEvent(this.addonName);
}

class ToggleChoiceEvent extends PizzaDetailsEvent {
  final String choiceName;
  ToggleChoiceEvent(this.choiceName);
}

// Select large option
class SelectLargeOptionEvent extends PizzaDetailsEvent {
  final String optionName;
  final double extraPrice;
  SelectLargeOptionEvent(this.optionName, this.extraPrice);
}


class UpdateQuantityEvent extends PizzaDetailsEvent {
  final int quantity;
  UpdateQuantityEvent(this.quantity);
}

abstract class PizzaDetailsEvent {}

class SelectSizeEvent extends PizzaDetailsEvent {
  final String size;
  SelectSizeEvent(this.size);
}

class ToggleAddonEvent extends PizzaDetailsEvent {
  final String addonName;
  ToggleAddonEvent(this.addonName);
}

// New event for Large sub-option selection
class SelectLargeOptionEvent extends PizzaDetailsEvent {
  final String optionName;
  final double extraPrice;
  SelectLargeOptionEvent(this.optionName, this.extraPrice);
}

// combo_details_state.dart
import 'package:pizza_boys/data/models/dish/dish_model.dart';

class ComboDetailsState {
  final DishModel comboDish;
  final List<bool> expandedSides;
  final Map<String, bool> selectedDishes;

  ComboDetailsState({
    required this.comboDish,
    required this.expandedSides,
    required this.selectedDishes,
  });

  ComboDetailsState copyWith({
    DishModel? comboDish,
    List<bool>? expandedSides,
    Map<String, bool>? selectedDishes,
  }) {
    return ComboDetailsState(
      comboDish: comboDish ?? this.comboDish,
      expandedSides: expandedSides ?? this.expandedSides,
      selectedDishes: selectedDishes ?? this.selectedDishes,
    );
  }
}

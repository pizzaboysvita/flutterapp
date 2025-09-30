import 'package:flutter_bloc/flutter_bloc.dart';
import 'pizza_details_event.dart';
import 'pizza_details_state.dart';

class PizzaDetailsBloc extends Bloc<PizzaDetailsEvent, PizzaDetailsState> {
  PizzaDetailsBloc() : super(PizzaDetailsState.initial()) {
    
    // 🔄 Reset handler
    on<ResetPizzaDetailsEvent>((event, emit) {
      emit(PizzaDetailsState.initial());
      print("♻️ Reset to initial state");
    });

on<ToggleBaseExpandEvent>((event, emit) {
  emit(state.copyWith(isBaseExpanded: !state.isBaseExpanded));
});


    // 👉 Handle base selection (radio)
    on<SelectBaseEvent>((event, emit) {
      emit(state.copyWith(
        selectedBase: event.baseName,
        baseExtraPrice: event.extraPrice,
      ));
      print("🍕 Base selected: ${event.baseName} | +${event.extraPrice}");
    });

    // 👉 Handle topping toggle (checkbox)
    on<ToggleToppingEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedToppings);
      updated[event.toppingName] = !(updated[event.toppingName] ?? false);

      // ✅ calculate total topping price
      double newPrice = 0;
      updated.forEach((name, selected) {
        if (selected) {
          newPrice += event.availableToppings[name] ?? 0;
        }
      });

      emit(state.copyWith(
        selectedToppings: updated,
        toppingsExtraPrice: newPrice,
      ));
      print("➕ Toppings total: $newPrice | selected: $updated");
    });

    // 👉 Handle sauces (increment/decrement with quantity)
    on<UpdateSauceQuantityEvent>((event, emit) {
      final updated = Map<String, int>.from(state.sauceQuantities);
      updated[event.sauceName] = event.quantity;

      double newPrice = 0;
      updated.forEach((name, qty) {
        newPrice += (event.availableSauces[name] ?? 0) * qty;
      });

      emit(state.copyWith(
        sauceQuantities: updated,
        saucesExtraPrice: newPrice,
      ));
      print("🥫 Sauces updated: $updated | total $newPrice");
    });

    // 👉 Handle ingredients (checkbox)
    on<ToggleIngredientEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedIngredients);
      updated[event.ingredientName] = !(updated[event.ingredientName] ?? false);

      emit(state.copyWith(selectedIngredients: updated));
      print("🥦 Ingredients: $updated");
    });

    // 👉 Handle choices (checkbox)
    on<ToggleChoiceEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedChoices);
      updated[event.choiceName] = !(updated[event.choiceName] ?? false);

      double newPrice = 0;
      updated.forEach((name, selected) {
        if (selected) newPrice += event.availableChoices[name] ?? 0;
      });

      emit(state.copyWith(
        selectedChoices: updated,
        choicesExtraPrice: newPrice,
      ));
      print("🍟 Choices total: $newPrice | $updated");
    });

    // 👉 Handle quantity of pizza
    on<UpdateQuantityEvent>((event, emit) {
      emit(state.copyWith(quantity: event.quantity));
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'pizza_details_event.dart';
import 'pizza_details_state.dart';

// ✅ Define addon & choice prices
final Map<String, double> addonPrices = {
  'Coke (500ml)': 1.5,   // fixed
  'Garlic Bread': 2.0,   // fixed
  'French Fries': 2.5,   // fixed
  'Extra Cheese': 2.0,
  'Olives': 1.5,
  // keep other items correct
};


final Map<String, double> choicePrices = {
  'Thin Crust': 0.0,
  'Cheese Burst': 2.5,
  'Stuffed Crust': 3.5,
};

class PizzaDetailsBloc extends Bloc<PizzaDetailsEvent, PizzaDetailsState> {
  PizzaDetailsBloc() : super(PizzaDetailsState.initial()) {
    
// 🔄 Reset handler
    on<ResetPizzaDetailsEvent>((event, emit) {
      emit(PizzaDetailsState.initial());
      print("♻️ PizzaDetailsBloc reset to initial state");
    });

    // 👉 Handle size selection
    on<SelectSizeEvent>((event, emit) {
      emit(state.copyWith(
        selectedSize: event.size,
        selectedLargeOption: null,
        largeOptionExtraPrice: 0,
      ));
    });

    // 👉 Handle addon toggle with price calculation
    on<ToggleAddonEvent>((event, emit) {
      final updatedAddons = Map<String, bool>.from(state.selectedAddons);
      updatedAddons[event.addonName] = !(updatedAddons[event.addonName] ?? false);

      // ✅ Calculate new addon total
      double newAddonPrice = 0;
      updatedAddons.forEach((name, selected) {
        if (selected) {
          newAddonPrice += addonPrices[name] ?? 0;
        }
      });

      emit(state.copyWith(
        selectedAddons: updatedAddons,
        addonExtraPrice: newAddonPrice,
      ));

      print("➕ addons total: $newAddonPrice | selected: $updatedAddons");
    });

    // 👉 Handle multiple choices (with price)
    on<ToggleChoiceEvent>((event, emit) {
      final updatedChoices = List<String>.from(state.selectedChoices);

      if (updatedChoices.contains(event.choiceName)) {
        updatedChoices.remove(event.choiceName);
      } else {
        updatedChoices.add(event.choiceName);
      }

      // ✅ Calculate choice price
      double newChoicePrice = 0;
      for (var choice in updatedChoices) {
        newChoicePrice += choicePrices[choice] ?? 0;
      }

      emit(state.copyWith(
        selectedChoices: updatedChoices,
        choiceExtraPrice: newChoicePrice,
      ));

      print("➕ choices total: $newChoicePrice | selected: $updatedChoices");
    });

    // 👉 Handle large option selection
    on<SelectLargeOptionEvent>((event, emit) {
      emit(state.copyWith(
        selectedLargeOption: event.optionName,
        largeOptionExtraPrice: event.extraPrice,
      ));
      print("➕ large option: ${event.optionName} | +${event.extraPrice}");
    });

    // 👉 Handle quantity update
    on<UpdateQuantityEvent>((event, emit) {
      emit(state.copyWith(quantity: event.quantity));
    });
  }
}

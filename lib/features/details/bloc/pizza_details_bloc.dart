import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/data/repositories/dish/dish_repo.dart';
import 'package:pizza_boys/data/services/dish/dish_service.dart';
import 'pizza_details_event.dart';
import 'pizza_details_state.dart';

class PizzaDetailsBloc extends Bloc<PizzaDetailsEvent, PizzaDetailsState> {
  final DishRepository dishRepository;

  PizzaDetailsBloc({DishRepository? dishRepository})
    : dishRepository = dishRepository ?? DishRepository(DishService()),
      super(PizzaDetailsState.initial()) {
    _registerHandlers();
  }

  void _registerHandlers() {
    on<ResetPizzaDetailsEvent>((event, emit) {
      emit(PizzaDetailsState.initial());
    });

    on<ToggleBaseExpandEvent>((event, emit) {
      emit(state.copyWith(isBaseExpanded: !state.isBaseExpanded));
    });

    on<SelectBaseEvent>((event, emit) {
      emit(
        state.copyWith(
          selectedBase: event.baseName,
          baseExtraPrice: event.extraPrice,
        ),
      );
    });

    on<SelectOptionSetRadioEvent>((event, emit) {
  final updatedOptions =
      Map<String, String>.from(state.selectedRadioOptions);
  final updatedPrices =
      Map<String, double>.from(state.radioExtraPrices);

  updatedOptions[event.optionSetName] = event.selectedOptionName;
  updatedPrices[event.optionSetName] = event.extraPrice;

  // ✅ Sum all radio prices
  double totalRadioPrice = 0;
  for (final p in updatedPrices.values) {
    totalRadioPrice += p;
  }

  emit(
    state.copyWith(
      selectedRadioOptions: updatedOptions,
      radioExtraPrices: updatedPrices,
      radiosExtraPrice: totalRadioPrice,
    ),
  );
});



    on<ToggleToppingEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedToppings);
      updated[event.toppingName] = !(updated[event.toppingName] ?? false);

      double newPrice = 0;
      updated.forEach((name, selected) {
        if (selected) newPrice += event.availableToppings[name] ?? 0;
      });

      emit(
        state.copyWith(selectedToppings: updated, toppingsExtraPrice: newPrice),
      );
    });

    on<UpdateSauceQuantityEvent>((event, emit) {
      final updated = Map<String, int>.from(state.sauceQuantities);
      updated[event.sauceName] = event.quantity;

      double newPrice = 0;
      updated.forEach((name, qty) {
        newPrice += (event.availableSauces[name] ?? 0) * qty;
      });

      emit(
        state.copyWith(sauceQuantities: updated, saucesExtraPrice: newPrice),
      );
    });

    on<ToggleIngredientEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedIngredients);
      updated[event.ingredientName] = !(updated[event.ingredientName] ?? true);
      emit(state.copyWith(selectedIngredients: updated));
    });

    on<ToggleChoiceEvent>((event, emit) {
      final updated = Map<String, bool>.from(state.selectedChoices);
      updated[event.choiceName] = !(updated[event.choiceName] ?? false);

      double newPrice = 0;
      updated.forEach((name, selected) {
        if (selected) newPrice += event.availableChoices[name] ?? 0;
      });

      emit(
        state.copyWith(selectedChoices: updated, choicesExtraPrice: newPrice),
      );
    });

    on<UpdateQuantityEvent>((event, emit) {
      emit(state.copyWith(quantity: event.quantity));
    });

    on<SelectComboDishEvent>((event, emit) {
      emit(state.copyWith(selectedComboDish: event.comboDish));
    });

    on<FetchComboDishDetailsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final storeIdStr = await TokenStorage.getChosenStoreId();
        final storeId = storeIdStr ?? "-1";
        final dish = await dishRepository.getDishById(event.dishId, storeId);

        emit(
          state.copyWith(
            selectedComboDish: dish ?? DishModelExtensionsEmpty.empty(),
            isLoading: false,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            selectedComboDish: DishModelExtensionsEmpty.empty(),
            isLoading: false,
            error: e.toString(),
          ),
        );
      }
    });
  }
}

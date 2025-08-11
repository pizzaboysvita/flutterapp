import 'package:flutter_bloc/flutter_bloc.dart';
import 'pizza_details_event.dart';
import 'pizza_details_state.dart';

class PizzaDetailsBloc extends Bloc<PizzaDetailsEvent, PizzaDetailsState> {
  PizzaDetailsBloc() : super(PizzaDetailsState.initial()) {
    on<SelectSizeEvent>((event, emit) {
      // Reset large option when changing size
      emit(state.copyWith(
        selectedSize: event.size,
        selectedLargeOption: null,
        largeOptionExtraPrice: 0,
      ));
    });

    on<ToggleAddonEvent>((event, emit) {
      final updatedAddons = Map<String, bool>.from(state.selectedAddons);
      updatedAddons[event.addonName] =
          !(updatedAddons[event.addonName] ?? false);
      emit(state.copyWith(selectedAddons: updatedAddons));
    });

    // Handle large option selection
    on<SelectLargeOptionEvent>((event, emit) {
      emit(state.copyWith(
        selectedLargeOption: event.optionName,
        largeOptionExtraPrice: event.extraPrice,
      ));
    });
  }
}

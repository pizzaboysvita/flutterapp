// combo_details_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/details/bloc/combo_event.dart';
import 'package:pizza_boys/features/details/bloc/combo_state.dart';

class ComboDetailsBloc extends Bloc<ComboDetailsEvent, ComboDetailsState> {
  ComboDetailsBloc({required DishModel comboDish})
    : super(
        ComboDetailsState(
          comboDish: comboDish,
          expandedSides: List.filled(comboDish.comboDishes.length, false),
          selectedDishes: {},
        ),
      ) {
    on<ToggleSideExpandEvent>(_onToggleSideExpand);
    on<ToggleDishSelectEvent>(_onToggleDishSelect);
  }

  void _onToggleSideExpand(
    ToggleSideExpandEvent event,
    Emitter<ComboDetailsState> emit,
  ) {
    final updated = List<bool>.from(state.expandedSides);
    updated[event.sideIndex] = !updated[event.sideIndex];
    emit(state.copyWith(expandedSides: updated));
  }

  void _onToggleDishSelect(
    ToggleDishSelectEvent event,
    Emitter<ComboDetailsState> emit,
  ) {
    final updated = Map<String, bool>.from(state.selectedDishes);
    updated["${event.dishId}"] = !(updated["${event.dishId}"] ?? false);
    emit(state.copyWith(selectedDishes: updated));
  }
}

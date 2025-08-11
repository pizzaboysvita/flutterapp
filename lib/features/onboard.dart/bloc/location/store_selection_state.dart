import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

abstract class StoreSelectionState {}

class StoreSelectionInitial extends StoreSelectionState {}

class StoreSelectionLoading extends StoreSelectionState {}

class StoreSelectionLoaded extends StoreSelectionState {
  final List<Store> stores;
  final String? selectedStoreId;

  StoreSelectionLoaded({
    required this.stores,
    this.selectedStoreId,
  });
}

class StoreSelectionError extends StoreSelectionState {
  final String message;
  StoreSelectionError(this.message);
}

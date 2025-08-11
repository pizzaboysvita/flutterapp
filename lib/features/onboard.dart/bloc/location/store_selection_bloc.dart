import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

abstract class StoreSelectionEvent {}

class LoadStoresEvent extends StoreSelectionEvent {}
class SelectStoreEvent extends StoreSelectionEvent {
  final String storeId;
  SelectStoreEvent(this.storeId);
}

class StoreSelectionBloc extends Bloc<StoreSelectionEvent, StoreSelectionState> {
  StoreSelectionBloc() : super(StoreSelectionInitial()) {
    on<LoadStoresEvent>(_onLoadStores);
    on<SelectStoreEvent>(_onSelectStore);
  }

  void _onLoadStores(
    LoadStoresEvent event,
    Emitter<StoreSelectionState> emit,
  ) async {
    emit(StoreSelectionLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulated delay

    final stores = [
      Store(id: '1', name: 'Glen Eden', address: '5/182 West Coast Road, Auckland'),
      Store(id: '2', name: 'Hillsborough', address: '161B Hillsborough Road, Auckland'),
      Store(id: '3', name: 'Ellerslie', address: '64 Michaels Avenue, Auckland'),
      Store(id: '4', name: 'Sandringham', address: '412 Sandringham Road, Auckland'),
      Store(id: '5', name: 'Flat Bush', address: '1 Arranmore Drive, Auckland'),
    ];

    emit(StoreSelectionLoaded(stores: stores));
  }

  void _onSelectStore(
    SelectStoreEvent event,
    Emitter<StoreSelectionState> emit,
  ) {
    if (state is StoreSelectionLoaded) {
      final currentState = state as StoreSelectionLoaded;
      emit(StoreSelectionLoaded(
        stores: currentState.stores,
        selectedStoreId: event.storeId,
      ));
    }
  }
}

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

/// ✅ Real-time ready, clean BLoC implementation
class StoreSelectionBloc extends Bloc<StoreSelectionEvent, StoreSelectionState> {
  final String _apiUrl = "http://78.142.47.247:3003/api/store?type=web";

  /// Keeps the selected store ID globally — persists until app restart
  int? selectedStoreId;

  StoreSelectionBloc() : super(StoreSelectionInitial()) {
    on<LoadStoresEvent>(_onLoadStores);
    on<SelectStoreEvent>(_onSelectStore);
  }

  /// Handles loading of stores
  Future<void> _onLoadStores(
    LoadStoresEvent event,
    Emitter<StoreSelectionState> emit,
  ) async {
    emit(StoreSelectionLoading());

    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final stores = data.map((e) => Store.fromJson(e)).toList();

        emit(StoreSelectionLoaded(
          stores: stores,
          selectedStoreId: selectedStoreId,
        ));
      } else {
        emit(StoreSelectionError("Failed to load stores. Code: ${response.statusCode}"));
      }
    } catch (e) {
      emit(StoreSelectionError("Error loading stores: $e"));
    }
  }

  /// Handles store selection
  void _onSelectStore(
    SelectStoreEvent event,
    Emitter<StoreSelectionState> emit,
  ) {
    selectedStoreId = event.storeId;

    if (state is StoreSelectionLoaded) {
      final loadedState = state as StoreSelectionLoaded;
      emit(
        loadedState.copyWith(selectedStoreId: selectedStoreId),
      );
    }
  }
}

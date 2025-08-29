import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_boys/core/constant/api_urls.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart'; // 👈 import TokenStorage
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

class StoreSelectionBloc
    extends Bloc<StoreSelectionEvent, StoreSelectionState> {
  final String _apiUrl = ApiUrls.storesGet;

  int? selectedStoreId;

  StoreSelectionBloc() : super(StoreSelectionInitial()) {
    on<LoadStoresEvent>(_onLoadStores);
    on<SelectStoreEvent>(_onSelectStore);
  }

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

        // 👇 Load saved store from storage
        final savedStoreId = await TokenStorage.getChosenStoreId();
        selectedStoreId = int.tryParse(savedStoreId ?? '');

        emit(
          StoreSelectionLoaded(
            stores: stores,
            selectedStoreId: selectedStoreId,
          ),
        );
      } else {
        emit(
          StoreSelectionError(
            "Failed to load stores. Code: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(StoreSelectionError("Error loading stores: $e"));
    }
  }

  Future<void> _onSelectStore(
    SelectStoreEvent event,
    Emitter<StoreSelectionState> emit,
  ) async {
    selectedStoreId = event.storeId;

    // ✅ Persist store selection
    final selectedStore = (state is StoreSelectionLoaded)
        ? (state as StoreSelectionLoaded).stores.firstWhere(
            (s) => s.id == event.storeId,
          )
        : null;

    if (selectedStore != null) {
      await TokenStorage.saveChosenLocation(
        storeId: selectedStore.id.toString(),
        locationName: selectedStore.name,
      );
    }

    if (state is StoreSelectionLoaded) {
      final loadedState = state as StoreSelectionLoaded;
      emit(loadedState.copyWith(selectedStoreId: selectedStoreId));
    }
  }
}

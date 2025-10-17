import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart'; // 👈 Dio helper
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';
import 'package:pizza_boys/core/constant/api_urls.dart';

class StoreSelectionBloc
    extends Bloc<StoreSelectionEvent, StoreSelectionState> {
  int? selectedStoreId;

  StoreSelectionBloc() : super(StoreSelectionInitial()) {
    on<LoadStoresEvent>(_onLoadStores);
    on<SelectStoreEvent>(_onSelectStore);
  }

  // ✅ Load stores using Dio
  Future<void> _onLoadStores(
    LoadStoresEvent event,
    Emitter<StoreSelectionState> emit,
  ) async {
    emit(StoreSelectionLoading());

    try {
      final response = await ApiClient.dio.get(ApiUrls.storesGet);

      // 🔹 Ignore handled errors (599) from ApiClient
      if (response.statusCode == 599) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data is List
            ? response.data
            : response.data['data'];
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
    } on DioException catch (e) {
      // ✅ Skip errors already handled by ApiClient
      if (e.response?.statusCode == 599 ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return;
      }

      emit(StoreSelectionError("Error loading stores: ${e.message}"));
    } catch (e) {
      emit(StoreSelectionError("Unexpected error loading stores: $e"));
    }
  }

  // ✅ Select store and persist
  Future<void> _onSelectStore(
    SelectStoreEvent event,
    Emitter<StoreSelectionState> emit,
  ) async {
    selectedStoreId = event.storeId;

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

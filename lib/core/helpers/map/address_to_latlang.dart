import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';

Future<LatLng> getStoreLatLng(Store store) async {
  // Safely handle nullable fields and remove empty components
  final fullAddress = [
    store.address,
    store.city ?? '',
    store.state ?? '',
    store.country ?? '',
    store.zipCode ?? '',
  ].where((e) => e.isNotEmpty).join(', ');

  // Log only the selected store's address

  try {
    final locations = await locationFromAddress(fullAddress);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {}

  return const LatLng(0, 0); // fallback
}

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
    store.zipCode ?? ''
  ].where((e) => e.isNotEmpty).join(', ');

  // Log only the selected store's address
  print("🏷️ Store Name: ${store.name}");
  print("📍 Street Address: ${store.address}");
  print("🏙️ City: ${store.city ?? ''}");
  print("🗺️ State: ${store.state ?? ''}");
  print("🌍 Country: ${store.country ?? ''}");
  print("📮 Zip Code: ${store.zipCode ?? ''}");
  print("📝 Full Address for geocoding: $fullAddress");

  try {
    final locations = await locationFromAddress(fullAddress);
    if (locations.isNotEmpty) {
      print("✅ LatLng found: ${locations.first.latitude}, ${locations.first.longitude}");
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    print("❌ Error geocoding store ${store.name}: $e");
  }

  print("⚠️ Using fallback LatLng (0,0) for ${store.name}");
  return const LatLng(0, 0); // fallback
}

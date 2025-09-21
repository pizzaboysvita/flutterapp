import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';

class Googlemap extends StatefulWidget {
  const Googlemap({super.key});

  @override
  State<Googlemap> createState() => _GooglemapState();
}

class Store {
  final String name;
  final String address;
  final String phone;
  final LatLng location;

  Store({
    required this.name,
    required this.address,
    required this.phone,
    required this.location,
  });
}

class _GooglemapState extends State<Googlemap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  List<Store> filteredStores = [];

  BitmapDescriptor? normalIcon;
  BitmapDescriptor? highlightedIcon;

  Store? selectedStore; // ✅ Track active store

  final List<Store> stores = [
    Store(
      name: "Pizza Boyz Glen Eden",
      address: "5/182 West Coast Road, Glen Eden, Auckland 0602",
      phone: "09 600 1116",
      location: LatLng(-36.9061, 174.6570),
    ),
    Store(
      name: "Pizza Boyz Hillsborough",
      address: "161B Hillsborough Road, Hillsborough, Auckland 1042",
      phone: "09 600 3367",
      location: LatLng(-36.9197, 174.7386),
    ),
    Store(
      name: "Pizza Boyz Ellerslie",
      address: "64 Michaels Avenue, Ellerslie, Auckland 1051, New Zealand",
      phone: "09 600 1231",
      location: LatLng(-36.8928, 174.8104),
    ),
    Store(
      name: "Pizza Boyz Sandringham",
      address: "412 Sandringham Road, Sandringham, Auckland 1025, New Zealand",
      phone: "09 200 3996",
      location: LatLng(-36.8840, 174.7400),
    ),
    Store(
      name: "Pizza Boyz Flat Bush",
      address: "1 Arranmore Drive, Flat Bush, Auckland 2019, New Zealand",
      phone: "09 883 5504",
      location: LatLng(-36.9514, 174.9093),
    ),
  ];

  final LatLng _initialLocation = const LatLng(-36.8485, 174.7633); // Auckland

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    filteredStores = stores;
  }

  /// Load both normal and highlighted icons
  Future<void> _loadCustomMarkers() async {
    normalIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(90, 90)),
      ImageUrls.circleLogo,
    );

    highlightedIcon = await _createBorderedMarker(ImageUrls.circleLogo);

    _setAllMarkers();
  }

  /// Draws a border around your logo dynamically
  Future<BitmapDescriptor> _createBorderedMarker(String assetPath) async {
    final image = await DefaultAssetBundle.of(context).load(assetPath);
    final codec = await ui.instantiateImageCodec(
      image.buffer.asUint8List(),
      targetWidth: 120,
    ); // slightly bigger
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..isAntiAlias = true;

    // Draw border circle
    paint.color = Colors.redAccent; // border color
    canvas.drawCircle(
      Offset(uiImage.width / 2, uiImage.height / 2),
      (uiImage.width / 2).toDouble(),
      paint,
    );

    // Draw actual logo
    final rect = Rect.fromLTWH(
      10,
      10,
      uiImage.width.toDouble() - 20,
      uiImage.height.toDouble() - 20,
    );
    paintImage(canvas: canvas, rect: rect, image: uiImage, fit: BoxFit.cover);

    final picture = pictureRecorder.endRecording();
    final finalImage = await picture.toImage(uiImage.width, uiImage.height);
    final byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _setAllMarkers() {
    _markers.clear();
    for (var store in stores) {
      final isSelected = store == selectedStore;

      _markers.add(
        Marker(
          markerId: MarkerId(store.name),
          position: store.location,
          icon: isSelected
              ? highlightedIcon ?? BitmapDescriptor.defaultMarker
              : normalIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: store.name,
            snippet: "${store.address}\n📞 ${store.phone}",
            onTap: () {
              _selectStore(store);
            },
          ),
          onTap: () {
            _selectStore(store);
          },
        ),
      );
    }
    setState(() {});
  }

  void _selectStore(Store store) {
    setState(() {
      selectedStore = store;
    });
    _goToStore(store);
    _setAllMarkers(); // refresh markers with highlight
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _searchStore(String query) {
    setState(() {
      filteredStores = stores
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _goToStore(Store store) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(store.location, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'Choose',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: 'Store',
                style: TextStyle(
                  color: AppColors.redAccent,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialLocation,
              zoom: 10.5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // 🔍 Search Box
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search Pizza Boyz store...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _searchStore,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: filteredStores.map((store) {
                        return ListTile(
                          title: Text(store.name),
                          subtitle: Text(store.address),
                          onTap: () {
                            _selectStore(store);
                            _searchController.clear();
                            filteredStores = stores;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

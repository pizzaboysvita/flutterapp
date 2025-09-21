import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/helpers/map/address_to_latlang.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class StoreSelectionPage extends StatefulWidget {
  final ScrollController? scrollController;
  const StoreSelectionPage({super.key, this.scrollController});

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {}; //Google-Map
  BitmapDescriptor? normalIcon;
  BitmapDescriptor? highlightedIcon;

  @override
  void initState() {
    super.initState();
    context.read<StoreSelectionBloc>().add(LoadStoresEvent());
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    normalIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(90, 90)),
      ImageUrls.circleLogo,
    );

    highlightedIcon = await _createBorderedMarker(ImageUrls.circleLogo);

    if (!mounted) return; // <-- check if widget is still in tree
    setState(() {});
  }

  Future<void> _updateMarkers(List<Store> stores, String? selectedId) async {
    _markers.clear();

    for (var store in stores) {
      final isSelected = store.id.toString() == selectedId;
      final storeLocation = await getStoreLatLng(store);

      _markers.add(
        Marker(
          markerId: MarkerId(store.id.toString()),
          position: storeLocation,
          icon: isSelected
              ? highlightedIcon ?? BitmapDescriptor.defaultMarker
              : normalIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () async {
            context.read<StoreSelectionBloc>().add(SelectStoreEvent(store.id));

            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(storeLocation, 15),
            );
          },
        ),
      );
    }

    if (!mounted) return; // <-- check before updating state
    setState(() {}); // refresh map
  }

  /// Draw logo with red border for selected marker
  Future<BitmapDescriptor> _createBorderedMarker(String assetPath) async {
    final image = await DefaultAssetBundle.of(context).load(assetPath);
    final codec = await ui.instantiateImageCodec(
      image.buffer.asUint8List(),
      targetWidth: 120,
    );
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..isAntiAlias = true;

    // Border circle
    paint.color = Colors.redAccent;
    canvas.drawCircle(
      Offset(uiImage.width / 2, uiImage.height / 2),
      (uiImage.width / 2).toDouble(),
      paint,
    );

    // Inner logo
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

  // .......... Google-Map ............
  Future<void> updateMarkers(List<Store> stores, String? selectedId) async {
    _markers.clear();

    for (var store in stores) {
      final isSelected = store.id.toString() == selectedId;
      final storeLocation = await getStoreLatLng(store);

      _markers.add(
        Marker(
          markerId: MarkerId(store.id.toString()),
          position: storeLocation,
          icon: isSelected
              ? highlightedIcon ?? BitmapDescriptor.defaultMarker
              : normalIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () async {
            context.read<StoreSelectionBloc>().add(SelectStoreEvent(store.id));

            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(storeLocation, 15),
            );
          },
        ),
      );
    }

    setState(() {}); // refresh map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // .................. Google-MAP ..........
              BlocListener<StoreSelectionBloc, StoreSelectionState>(
                listener: (context, state) {
                  if (state is StoreSelectionLoaded) {
                    _updateMarkers(
                      state.stores,
                      state.selectedStoreId?.toString(),
                    );
                    setState(
                      () {},
                    ); // ✅ safe, because it's outside the build process
                  }
                },
                child: BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
                  builder: (context, state) {
                    if (state is StoreSelectionLoaded) {
                      return Column(
                        children: [
                          Container(
                            height: 200.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: GoogleMap(
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                                initialCameraPosition: CameraPosition(
                                  target: _getStoreLocation(
                                    state.stores.first.id,
                                  ),
                                  zoom: 10.5,
                                ),
                                markers: _markers,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                              ),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton.icon(
                          //     onPressed: () {
                          //       Navigator.pushNamed(
                          //         context,
                          //         AppRoutes.googleMaps,
                          //       );
                          //     },
                          //     icon: const Icon(
                          //       Icons.fullscreen,
                          //       color: Colors.red,
                          //     ),
                          //     label: const Text(
                          //       "View Full Map",
                          //       style: TextStyle(color: Colors.red),
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    }
                    return Container(
                      height: 200.h,
                      color: Colors.grey.shade200,
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),
              Text(
                "Choose Your Nearby Store",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.redPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Select the store nearest to you for pickup or delivery.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20.h),

              // 🔥 Store List
              Expanded(
                child: BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
                  builder: (context, state) {
                    if (state is StoreSelectionLoading) {
                      return _buildShimmerList();
                    } else if (state is StoreSelectionLoaded) {
                      return _buildStoreList(state);
                    } else if (state is StoreSelectionError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ Bottom Continue Button
      bottomNavigationBar: BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
        builder: (context, state) {
          if (state is StoreSelectionLoaded && state.selectedStoreId != null) {
            return buildBottomSummary(context);
          }
          return const SizedBox.shrink();
          // return buildBottomSummary(context);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildStoreList(StoreSelectionLoaded state) {
    return ListView.separated(
      itemCount: state.stores.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final store = state.stores[index];
        final isSelected = store.id == state.selectedStoreId;
        return InkWell(
          onTap: () async {
            // ✅ Use dot notation, not square brackets
            context.read<StoreSelectionBloc>().add(
              SelectStoreEvent(store.id), // store.id, not store['store_id']
            );

            // Get coordinates dynamically
            final latLng = await getStoreLatLng(store);
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(latLng, 15),
            );
          },

          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        store.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: Colors.red, size: 22.sp),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: AppColors.blackColor,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        store.address,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.call, size: 14.sp, color: AppColors.blackColor),
                    SizedBox(width: 4.w),
                    Text(
                      store.phone,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildBottomSummary(BuildContext context) {
    return BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
      builder: (context, state) {
        if (state is! StoreSelectionLoaded || state.selectedStoreId == null) {
          return const SizedBox.shrink(); // don’t show button if nothing selected
        }

        final selectedStore = state.stores.firstWhere(
          (store) => store.id == state.selectedStoreId,
        );

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // ✅ Save selected store to secure storage
                    await TokenStorage.saveChosenLocation(
                      storeId: selectedStore.id.toString(),
                      locationName: selectedStore.name,
                    );

                    debugPrint(
                      "✅ Store persisted: ${selectedStore.name} (ID: ${selectedStore.id})",
                    );

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                    ), // ✅ Adaptive padding
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 14.sp, // ✅ Slightly larger font for readability
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LatLng _getStoreLocation(int storeId) {
    switch (storeId) {
      case 1:
        return const LatLng(-36.8485, 174.7633); // Example: Auckland
      case 2:
        return const LatLng(-37.8136, 144.9631); // Example: Melbourne
      case 3:
        return const LatLng(-33.8688, 151.2093); // Example: Sydney
      default:
        return const LatLng(-36.8485, 174.7633); // fallback
    }
  }
}

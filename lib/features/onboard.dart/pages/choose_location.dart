import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/map/address_to_latlang.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class StoreSelectionPage extends StatefulWidget {
  final ScrollController? scrollController;
  final bool isChangeLocation;
  const StoreSelectionPage({
    super.key,
    this.scrollController,
    this.isChangeLocation = false,
  });

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
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
      ImageUrls.circleLogoPng,
    );

    highlightedIcon = await _createBorderedMarker(ImageUrls.circleLogoPng);

    if (!mounted) return; // <-- check if widget is still in tree
    setState(() {});
  }

  Future<BitmapDescriptor> _createLogoPinMarker(ui.Image logoImage) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..isAntiAlias = true;

    const double circleRadius = 50; // radius of circle/logo
    const double stickHeight = 60; // length of stick
    const double stickWidth = 12; // width of stick

    final double totalHeight = circleRadius * 2 + stickHeight + 20;

    final double centerX = circleRadius;
    final double shadowCenterY = totalHeight - 10; // shadow near bottom

    // === Shadow at Bottom ===
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, shadowCenterY),
        width: circleRadius * 1.4,
        height: 14,
      ),
      paint,
    );

    // === Stick ===
    paint.color = Colors.black;
    final stickTopY =
        shadowCenterY - stickHeight; // stick ends at bottom of circle
    final stickRect = Rect.fromLTWH(
      centerX - stickWidth / 2,
      stickTopY,
      stickWidth,
      stickHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(stickRect, const Radius.circular(3)),
      paint,
    );

    // === Circle Head (outer ring) ===
    paint.color = Colors.white;
    final circleCenterY = stickTopY; // circle sits on top of stick
    canvas.drawCircle(Offset(centerX, circleCenterY), circleRadius, paint);

    // === Inner Circle (theme color) ===
    paint.color = Colors.red;
    canvas.drawCircle(Offset(centerX, circleCenterY), circleRadius - 6, paint);

    // === Inner border ===
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.black;
    canvas.drawCircle(Offset(centerX, circleCenterY), circleRadius - 6, paint);

    // === Draw Logo in Center ===
    final logoSize = 55.0;
    final src = Rect.fromLTWH(
      0,
      0,
      logoImage.width.toDouble(),
      logoImage.height.toDouble(),
    );
    final dst = Rect.fromCenter(
      center: Offset(centerX, circleCenterY),
      width: logoSize,
      height: logoSize,
    );
    paint.style = PaintingStyle.fill;
    canvas.drawImageRect(logoImage, src, dst, paint);

    // === Export ===
    final img = await pictureRecorder.endRecording().toImage(
      (circleRadius * 2).toInt(),
      totalHeight.toInt(),
    );

    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<ui.Image> _loadLogo(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _updateMarkers(List<Store> stores, String? selectedId) async {
    final logo = await _loadLogo(ImageUrls.circleLogoPng);
    final customPin = await _createLogoPinMarker(logo);

    _markers.clear();

    for (var store in stores) {
      final storeLocation = await getStoreLatLng(store);

      _markers.add(
        Marker(
          markerId: MarkerId(store.id.toString()),
          position: storeLocation,
          // Custom Logo Marker with red border if selected
          // icon: isSelected
          //     ? highlightedIcon ?? BitmapDescriptor.defaultMarker
          //     : normalIcon ?? BitmapDescriptor.defaultMarker,

          // GMap default red pin, highlighted if selected
          icon: customPin,
          anchor: const Offset(0.5, 1.0),

          onTap: () async {
            context.read<StoreSelectionBloc>().add(SelectStoreEvent(store.id));

            await moveCameraSafely(storeLocation);
          },
        ),
      );
    }

    if (!mounted) return;
    setState(() {});
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

  Future<void> _safeAnimateCamera(CameraUpdate update) async {
    if (_mapController != null) {
      try {
        await _mapController!.animateCamera(update);
      } catch (e) {}
    } else {}
  }

  Future<void> moveCameraSafely(LatLng target) async {
    // ⏳ wait until map + UI + GPU are fully ready (important for iPhone 13)
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted || _mapController == null) return;

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(target, 14),
      );
    } catch (_) {
      // silently ignore to avoid iOS crash
    }
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

            _safeAnimateCamera(CameraUpdate.newLatLngZoom(storeLocation, 15));
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
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // .................. Google-MAP ..........
            BlocListener<StoreSelectionBloc, StoreSelectionState>(
              listener: (context, state) async {
                if (state is StoreSelectionLoaded) {
                  // 1️⃣ Load markers first
                  await _updateMarkers(
                    state.stores,
                    state.selectedStoreId?.toString(),
                  );

                  // 2️⃣ Safely move camera AFTER markers are ready
                  if (state.selectedStoreId != null) {
                    final selectedStore = state.stores.firstWhere(
                      (s) => s.id == state.selectedStoreId,
                    );

                    final latLng = await getStoreLatLng(selectedStore);
                    await moveCameraSafely(latLng);
                  } else {
                    // No selection → fit all markers (safe)
                    await _fitMarkersToBounds(state.stores);
                  }
                }
              },
              child: BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
                builder: (context, state) {
                  if (state is StoreSelectionLoaded) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 200.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: LatLng(20.5937, 78.9629), // India
                                zoom: 4,
                              ),

                              onMapCreated: (controller) {
                                _mapController = controller;
                              },

                              markers: _markers,

                              // ❗ VERY IMPORTANT
                              myLocationEnabled:
                                  false, // enable AFTER permission
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Container(height: 200.h, color: Colors.grey.shade200);
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
                    print(state.message);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
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
            await moveCameraSafely(latLng);
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
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              _isLoading.value = true;

                              // 1️⃣ Save location & store
                              await TokenStorage.saveChosenLocation(
                                storeId: selectedStore.id.toString(),
                                locationName: selectedStore.name,
                              );

                              await TokenStorage.saveSelectedStore(
                                selectedStore,
                              );
                              await TokenStorage.setLocationChosen(true);

                              // 2️⃣ Update current store in cubit
                              final storeId = selectedStore.id.toString();
                              context.read<StoreWatcherCubit>().updateStore(
                                storeId,
                                selectedStore.name,
                              );

                              // 3️⃣ Trigger favorites fetch for the current store
                              context.read<FavoriteBloc>().add(
                                FetchWishlistEvent(storeId: storeId),
                              );

                              _isLoading.value = false;

                              // 4️⃣ Navigate
                              if (widget.isChangeLocation) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.home,
                                  (route) => false,
                                );
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fitMarkersToBounds(List<Store> stores) async {
    if (_mapController == null || stores.isEmpty) return;

    final List<LatLng> positions = [];
    for (var store in stores) {
      final loc = await getStoreLatLng(store);
      positions.add(loc);
    }

    if (positions.isEmpty) return;

    final bounds = _createLatLngBounds(positions);
    _safeAnimateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _createLatLngBounds(List<LatLng> positions) {
    // Assume at least one position exists (safe since we check before calling)
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var latLng in positions) {
      if (latLng.latitude < minLat) minLat = latLng.latitude;
      if (latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (latLng.longitude < minLng) minLng = latLng.longitude;
      if (latLng.longitude > maxLng) maxLng = latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

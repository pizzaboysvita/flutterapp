import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_bloc.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_event.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/dialogs/offers_popup.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';

import 'package:pizza_boys/features/home/widgets/accordian.dart';
import 'package:pizza_boys/features/home/widgets/dashboard_hero.dart';
import 'package:pizza_boys/features/home/widgets/popular_picks.dart';
import 'package:pizza_boys/features/home/widgets/promotional_banner.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/features/onboard.dart/model/store_selection_model.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Home extends StatefulWidget {
  final ScrollController scrollController;
  const Home({super.key, required this.scrollController});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  bool _hasShownPopup = false;
  bool _isFabVisible = true;
  late VoidCallback _scrollListener;

  @override
  bool get wantKeepAlive => true;

@override
void initState() {
  super.initState();
  print("🔹 Home initState called");

  // Scroll listener
  _scrollListener = () {
    final direction = widget.scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }
  };
  widget.scrollController.addListener(_scrollListener);

  // ✅ Safe post-frame callback
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return; // prevent using context after dispose
    print("🔹 Post-frame callback triggered");

    final storeIdStr = await TokenStorage.getChosenStoreId();
    final storeId = int.tryParse(storeIdStr ?? "-1") ?? -1;
    print("🔹 Current chosen storeId: $storeId");

    if (!mounted) return; // safety check before accessing context
    if (storeId != -1) {
      print("🔹 Dispatching FetchPromos for storeId: $storeId");
      context.read<PromoBloc>().add(FetchPromos(storeId));
    } else {
      print("⚠️ No valid storeId found, cannot fetch promos");
    }
  });
}


StreamSubscription? _promoSubscription;


@override
void dispose() {
  print("🔹 Home dispose called");
  widget.scrollController.removeListener(_scrollListener);
  _promoSubscription?.cancel();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<PromoBloc, PromoState>(
    listener: (context, state) async {
    print("🔹 PromoBloc emitted state: $state");

    if (!_hasShownPopup && mounted) {
  if (state is PromoLoaded && state.promos.isNotEmpty) {
    _hasShownPopup = true;
    print("🔹 Triggering showDynamicPopups now");
    showDynamicPopups(context, state.promos);
  }
}
else {
      print("🔹 Popup already shown, skipping...");
    }
  },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.0.w),
                child: Image.asset(
                  ImageUrls.logoWhite, // replace with your image path
                  height: 22.sp, // matches your text height
                  fit: BoxFit.contain,
                ),
              ),
      
              BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
                builder: (context, state) {
                  String selectedStore = "Select Store";
      
                  if (state is StoreSelectionLoaded) {
                    final current = state.stores.firstWhere(
                      (store) => store.id == state.selectedStoreId,
                      orElse: () => Store(
                        id: 0,
                        name: "",
                        address: "",
                        phone: "",
                        image: "",
                      ),
                    );
      
                    if (current.id != 0 && current.name.isNotEmpty) {
                      selectedStore = current.name;
                      // 💾 Persist selection
                      TokenStorage.saveSelectedStore(current);
                    }
                  }
      
                  return FutureBuilder<String?>(
                    future: TokenStorage.loadSelectedStoreName(),
                    builder: (context, snapshot) {
                      final storedName = snapshot.data;
                      // if Bloc didn’t give valid name, fallback to stored one
                      if (selectedStore == "Select Store" &&
                          storedName != null &&
                          storedName.isNotEmpty) {
                        selectedStore = storedName;
                      }
      
                      return InkWell(
                        onTap: () async {
                          final changed = await Navigator.pushNamed(
                            context,
                            AppRoutes.chooseStoreLocation,
                            arguments: {"isChangeLocation": true},
                          );
      
                          debugPrint(
                            "⬅️ Returned from Location page → changed = $changed",
                          );
      
                          if (changed == true) {
                            context.read<StoreSelectionBloc>().add(
                              LoadStoresEvent(),
                            );
                          } else {
                            debugPrint(
                              "⚠️ No store change detected → keeping stored store",
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.whiteColor,
                              size: 14.w,
                            ),
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Text(
                                selectedStore,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            IconAccordion(),
            SizedBox(width: 6.0.w),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              controller: widget.scrollController,
              children: [
                Column(
                  children: [
                    const DashboardHeroSection(),
      
                    SizedBox(height: 20.h),
                    const PromotionalBanner(),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pizza Categories',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const PizzaCategoriesRow(),
                    SizedBox(height: 8.h),
                    const PopularPicks(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ],
            ),
      
            // Floating Search Button
            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isFabVisible ? 1 : 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.searchView);
                    },
                    child: Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.black, Color(0xFFB71C1C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(FontAwesomeIcons.search, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _showStoreSelectionBottomSheet(BuildContext context) async {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent, // optional for rounded corners
  //     builder: (ctx) {
  //       return DraggableScrollableSheet(
  //         initialChildSize: 0.8, // 70% of screen height
  //         minChildSize: 0.6,
  //         maxChildSize: 0.95,
  //         expand: false,
  //         builder: (context, scrollController) {
  //           return Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //             ),
  //             child: StoreSelectionPage(
  //               scrollController:
  //                   scrollController, // pass it to your ListView inside page
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}

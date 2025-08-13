import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_bloc.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_event.dart';
import 'package:pizza_boys/features/onboard.dart/bloc/location/store_selection_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class StoreSelectionPage extends StatefulWidget {
  const StoreSelectionPage({super.key});

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  @override
  @override
  void initState() {
    super.initState();
    // Start loading stores immediately
    context.read<StoreSelectionBloc>().add(LoadStoresEvent());
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
              // Preloaded Lottie - shows instantly
              Center(
                child: Lottie.asset(
                  'assets/lotties/Dlivery Map.json',
                  height: 190.h,
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
      bottomNavigationBar: BlocBuilder<StoreSelectionBloc, StoreSelectionState>(
        builder: (context, state) {
          if (state is StoreSelectionLoaded && state.selectedStoreId != null) {
            return buildBottomSummary(context);
          }
          return const SizedBox.shrink();
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
        onTap: () {
          context.read<StoreSelectionBloc>().add(SelectStoreEvent(store.id));
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
                  Icon(Icons.location_on, size: 16.sp, color: AppColors.blackColor),
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
              Padding(
                padding: EdgeInsets.only(left: 3.0.w),
                child: Row(
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
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget buildBottomSummary(BuildContext context) {
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
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
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
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/price_summary/price_summary.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class OrderTracking extends StatefulWidget {
  const OrderTracking({super.key});

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Placeholder
            Container(
              height: 300.h,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Image.asset(ImageUrls.dummyMap, fit: BoxFit.cover),
            ),

            // Order Card
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(),
                  SizedBox(height: 20.h),
                  _buildTimeline(),
                  SizedBox(height: 10.h),
                  _buildSeeMoreButton(),
                  if (showMore) ...[
                    SizedBox(height: 10.h),
                    _buildPaymentSummary(),
                  ],
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomSummary(),
    );
  }

  Widget _buildBottomSummary() {
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
                'Back to Home',
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

  Widget _buildOrderHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage("https://i.imgur.com/BoN9kdC.png"),
          radius: 22.r,
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pizza Order",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "28 July 2025 11:30 AM",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        Spacer(),
        Icon(FontAwesomeIcons.phone, color: AppColors.blackColor, size: 20.sp),
        SizedBox(width: 15.w),
        Icon(
          FontAwesomeIcons.solidMessage,
          color: AppColors.blackColor,
          size: 20.sp,
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    final timeline = [
      {
        'title': 'Address',
        'subtitle':
            '64 Michaels Avenue, Ellerslie\n, Auckland 1051, New Zealand',
        'status': true,
      },
      {
        'title': 'Order Placed',
        'subtitle': '28 July 2025 11:15 AM',
        'status': true,
      },
      {
        'title': 'Preparing',
        'subtitle': 'Chef started preparing your order',
        'status': true,
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Your pizza is on the way',
        'status': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: timeline.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  width: 10.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item['status'] == true
                        ? AppColors.redAccent
                        : Colors.grey.shade400,
                  ),
                ),
                if (item != timeline.last)
                  Container(
                    width: 2.w,
                    height: 40.h,
                    color: AppColors.redAccent.withOpacity(0.4),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'].toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item['subtitle'].toString(),
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSeeMoreButton() {
    return InkWell(
      onTap: () {
        setState(() {
          showMore = !showMore;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            showMore ? "See Less" : "See More",
            style: TextStyle(
              color: AppColors.redAccent,
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              fontFamily: 'Poppins',
            ),
          ),
          Icon(
            showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 30.h),
        Text(
          "Order Details",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Icon(
              FontAwesomeIcons.creditCard,
              size: 18.sp,
              color: Colors.deepOrange,
            ),
            SizedBox(width: 10.w),
            Text(
              "Paid with **** **** **** 4567",
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
            ),
            Spacer(),
            Icon(Icons.check_circle, color: AppColors.greenColor, size: 16.sp),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          "Summary",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 10.h),
        PriceSummaryWidget(
          itemName: 'Cheese Lovers Pizza',
          size: 'Small',
          price: 14.50,
          gst: 1.89,
          quantity: 1,
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text.rich(
        TextSpan(
          text: 'Order',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Tracking',
              style: TextStyle(color: AppColors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

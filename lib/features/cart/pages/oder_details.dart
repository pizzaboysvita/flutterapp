import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/price_summary/price_summary.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ✅ Payment Success Block
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 80.h,
                    width: 80.w,
                    child: Lottie.asset(
                      LottieUrls.paymentSuccess,
                      repeat: false,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Payment Successful",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: AppColors.greenColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Thank you for your order!",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.blackColor.withOpacity(0.3),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _sectionCard(
              title: "Delivery Information",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile("Name", "Sandringham"),
                  _infoTile("Phone", "09 200 3996"),
                  _infoTile(
                    "Address",
                    "412 Sandringham Road, Sandringham, Auckland 1025, New Zealand",
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            _sectionCard(
              title: "Order Items",
              child: Column(
                children: [
                  _orderItemTile("M and M Pizza", 1, 8.99),
                  // _orderItemTile("Garlic Bread", 1, 2.00),
                  // _orderItemTile("Coke", 1, 1.50),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            PriceSummaryWidget(
              subtotal: 8.99,
              vat: 0.5,
              shipping: 2.0,
              discount: 1.5,
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
                Navigator.pushNamed(context, AppRoutes.orderTracking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Track Order',
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

  Widget _buildStepsIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      child: Row(
        children: [
          _stepIcon(Icons.location_on, true),
          Expanded(child: _dottedLine()),
          _stepIcon(Icons.payment, true),
          Expanded(child: _dottedLine()),
          _stepIcon(Icons.check_circle, true), // active on final page
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, bool active) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: active ? AppColors.blackColor : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Icon(
        icon,
        size: 18.sp,
        color: active ? Colors.white : Colors.grey,
      ),
    );
  }

  Widget _dottedLine() {
    return LayoutBuilder(
      builder: (_, box) {
        final count = (box.maxWidth / 16).floor();
        return Padding(
          padding: EdgeInsets.all(12.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(count, (_) {
              return Container(
                width: 5.w,
                height: 2.h,
                color: Colors.grey.shade400,
              );
            }),
          ),
        );
      },
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderItemTile(String name, int qty, double price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$name x$qty",
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          Text(
            "\$${(price * qty).toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
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
              text: ' Details',
              style: TextStyle(color: AppColors.redAccent),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: _buildStepsIndicator(),
      ),
    );
  }



}

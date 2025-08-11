import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/cart/bloc/payment/payments_cubit.dart';
import 'package:pizza_boys/features/cart/widgets/payments/coupon_input.dart';
import 'package:pizza_boys/features/cart/widgets/payments/payment_tile.dart';
import 'package:pizza_boys/core/reusable_widgets/price_summary/price_summary.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class PaymentPage extends StatelessWidget {
  PaymentPage({super.key});
  final TextEditingController couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionTitle('Payment Options'),
              SizedBox(height: 15.h),
              const PaymentMethodTile(title: 'Card Online', value: 'card'),
              const PaymentMethodTile(title: 'Bank Transfer', value: 'bank'),

              // const PaymentMethodTile(title: 'Paytm', value: 'paytm'),
              // const PaymentMethodTile(title: 'UPI', value: 'upi'),
              // const PaymentMethodTile(title: 'WhatsApp Pay', value: 'whatsapp'),
              SizedBox(height: 20.h),
              CouponInput(
                controller: couponController,
                onApply: () {
                  context.read<PaymentCubit>().applyCoupon(
                    couponController.text.trim(),
                  );
                },
              ),

              SizedBox(height: 30.h),
              PriceSummaryWidget(
                itemName: 'Cheese Lovers Pizza',
                size: 'Small',
                price: 14.50,
                gst: 1.89,
                quantity: 1,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomPayButton(context),
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
          text: 'Payment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Method',
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

  Widget _buildStepsIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      child: Row(
        children: [
          _stepIcon(Icons.location_on, true),
          Expanded(child: _dottedLine()),
          _stepIcon(Icons.payment, true),
          Expanded(child: _dottedLine()),
          _stepIcon(Icons.check_circle, false),
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

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBottomPayButton(BuildContext context) {
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
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.orderDetails);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.redPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Pay Now',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

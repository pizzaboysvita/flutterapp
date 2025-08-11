import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/cart/bloc/checkout/checkout_cubit.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: BlocBuilder<CheckoutCubit, CheckoutState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _deliveryToggleRow(context, state),
                  SizedBox(height: 24.h),
                  if (state.isHomeDelivery == false) _buildPickupOptions(),
                  if (state.isHomeDelivery == true) _buildDeliveryForm(),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(
                        value: state.saveAddress,
                        onChanged: (v) =>
                            context.read<CheckoutCubit>().toggleSaveAddress(v!),
                        activeColor: AppColors.blackColor,
                        side: BorderSide(color: Colors.black),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Save this address for future checkout',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSummary(),
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
          text: 'Shipping',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Order',
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

  Widget _deliveryToggleRow(BuildContext context, CheckoutState state) {
    return Row(
      children: [
        _deliveryToggle(context, 'Home Delivery', false, state),
        SizedBox(width: 12.w),
        _deliveryToggle(context, 'Pick-Up Point', true, state),
      ],
    );
  }

  Widget _deliveryToggle(
    BuildContext context,
    String label,
    bool val,
    CheckoutState state,
  ) {
    final sel = state.isHomeDelivery != val;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<CheckoutCubit>().toggleDeliveryMethod(!val),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: sel ? AppColors.redPrimary : Colors.transparent,
            ),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Poppins',
                color: sel ? AppColors.redPrimary : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
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
          _stepIcon(Icons.payment, false),
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

  Widget _buildDeliveryForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(child: _formField('Full Name')),
              SizedBox(width: 12.w),
              Flexible(child: _formField('Mobile')),
            ],
          ),
          _formField('Building, Street'),
          Row(
            children: [
              Flexible(child: _formField('City')),
              SizedBox(width: 12.w),
              Flexible(child: _formField('ZIP / PIN')),
            ],
          ),
          _formField('Country'),
        ],
      ),
    );
  }

  Widget _formField(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12.sp,
            fontFamily: 'Poppins',
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.redPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pick-Up Locations'),
        SizedBox(height: 10.h),
        _pickupTile(
          'Pizza Boys • Glen Eden',
          '5/182 West Coast Road, Auckland',
        ),
        _pickupTile(
          'Pizza Boys • Hillsborough',
          '161B Hillsborough Road, Auckland',
        ),
        _pickupTile(
          'Pizza Boys • Ellerslie',
          '64 Michaels Avenue,  New Zealand',
        ),
        _pickupTile('Pizza Boys • Flat Bush', ' Arranmore Drive,  New Zealand'),
      ],
    );
  }

  Widget _pickupTile(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(Icons.store, size: 26.sp, color: AppColors.blackColor),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
        color: Colors.black87,
      ),
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
          _priceRow('Subtotal', '\$8.99'),
          _priceRow('Shipping Fee', '\$2.00'),
          Divider(color: Colors.grey.shade300),
          _priceRow('Total', '\$10.99', isBold: true, isGreen: true),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.payments);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Proceed to Payment',
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

  Widget _priceRow(
    String label,
    String amount, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isGreen ? AppColors.greenColor : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

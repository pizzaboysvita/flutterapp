import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class CouponInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final String label;

  const CouponInput({
    super.key,
    required this.controller,
    required this.onApply,
    this.label = "Enter Coupon Code",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
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
        ),
        SizedBox(width: 12.w),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blackColor,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: onApply,
          child: Text(
            'Apply',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

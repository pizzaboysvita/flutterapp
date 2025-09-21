import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class StartupOfferPopup extends StatelessWidget {
  const StartupOfferPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Exclusive Offers for You!",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "🔥 Combo Deals starting at \$9.99\n🎁 Flat 30% OFF on first order\n💰 Earn SuperCoins on every purchase",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 36.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Let's Explore!",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

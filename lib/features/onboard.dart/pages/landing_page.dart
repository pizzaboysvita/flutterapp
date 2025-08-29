import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(ImageUrls.landingImage, fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
          ),
          Positioned(
            top: 35.h,
            left: 30.w,
            right: 30.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "PIZZA ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: "BOYZ",
                        style: TextStyle(
                          color: AppColors.redAccent,
                          fontSize: 18.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 80.h,
            left: 24.w,
            right: 24.w,
            child: Column(
              children: [
                Text(
                  "Fresh Pizza Delivered Fast with Just One Click!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Top-quality pizzas across Auckland, \n order online for pickup or delivery!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                 onPressed: () => Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.login,
  (route) => false, // removes all previous routes
),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    elevation: 2,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class MaintenanceScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MaintenanceScreen({Key? key, required this.message, this.onRetry})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColorLight,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie animation
              SizedBox(
                height: 0.4.sh,
                child: Lottie.asset(
                  LottieUrls.maintenance,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 20.h),

              // Title with RichText style
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "App ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextSpan(
                      text: "Under Maintenance",
                      style: TextStyle(
                        color: AppColors.redAccent,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Message
              Text(
                message.isNotEmpty
                    ? message
                    : "We’re making improvements. Please check back later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
              ),

              SizedBox(height: 20.h),

              // Retry button
              SizedBox(
                width: 0.5.sw,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 4,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: onRetry ?? () {},
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text(
                    "Retry",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

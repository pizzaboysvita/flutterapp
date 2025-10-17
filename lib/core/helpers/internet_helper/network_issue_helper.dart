import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class NetworkIssueScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkIssueScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(systemOverlayStyle: SystemUiOverlayStyle.light),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// 🍕 Lottie animation
              SizedBox(
                height: 0.4.sh, // 30% of screen height
                child: Lottie.asset(
                  'assets/lotties/network_issue.json',
                  fit: BoxFit.contain,
                ),
              ),
              // SizedBox(height: 25.h),

              /// Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Oops! ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp, // responsive
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextSpan(
                      text: "You're Offline",
                      style: TextStyle(
                        color: AppColors.redAccent,
                        fontSize: 20.sp, // responsive
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              /// Subtitle (fit in 2 lines)
              Text(
                "We can’t deliver fresh pizzas without internet. "
                "Check your connection and try again.",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),

              /// Retry button
              SizedBox(
                width: 0.5.sw, // 50% of screen width
                // height: 48.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 4,
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                  ),
                  onPressed: onRetry,
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text(
                    "Try Again",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

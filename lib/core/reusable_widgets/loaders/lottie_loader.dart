import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';

class LottieLoader extends StatelessWidget {
  final double? size;
  final String assetPath;

  const LottieLoader({
    super.key,
    this.size, // allow override
    this.assetPath = LottieUrls.pizzaLoading, // default loader path
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: (size ?? 120).h,
            width: (size ?? 120).w,
            child: Lottie.asset(assetPath, fit: BoxFit.contain),
          ),
          Text(
            'Loading...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              letterSpacing: 0.5, // ✅ little polish
            ),
          ),
        ],
      ),
    );
  }
}

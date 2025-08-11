import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class MealAddonTile extends StatelessWidget {
  final Map<String, dynamic> addon;
  final VoidCallback onToggle;

  const MealAddonTile({super.key, required this.addon, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isAdded = addon['added'];

    return Container(
      width: 110.w, // 💥 Slightly Increased Width
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAdded ? Colors.red.shade50 : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        // border: Border.all(color: isAdded ? Colors.red : Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            addon['image'],
            width: 60.w,
            height: 60.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 2.h),
          Flexible(
            child: Text(
              addon['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp, // 💥 Slightly Reduced Font
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '\$${addon['price'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            height: 24.h, // 💥 Slightly Reduced Height
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdded ? AppColors.redPrimary : Colors.black,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: Text(
                isAdded ? 'Added' : 'Add',
                style: TextStyle(
                  fontSize: 9.sp,
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
}

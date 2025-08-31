import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              item['image'],
              width: 60.w,
              height: 60.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${item['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: FaIcon(FontAwesomeIcons.minus, size: 14.sp),
              ),
              Text(
                '${item['quantity']}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: FaIcon(
                  FontAwesomeIcons.plus,
                  size: 14.sp,
                  color: AppColors.redPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

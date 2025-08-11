
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class CartCouponTile extends StatelessWidget {
  final void Function(double) onApplyCoupon;
  final void Function(bool) onToggleSuperCoins;
  final bool isSuperCoinsUsed;

  const CartCouponTile({
    super.key,
    required this.onApplyCoupon,
    required this.onToggleSuperCoins,
    required this.isSuperCoinsUsed,
  });

  void _showCouponSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apply Coupon',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 12.h),
            ListTile(
              title: Text(
                'FLAT50 - ₹50 off',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onTap: () {
                Navigator.pop(context);
                onApplyCoupon(50);
              },
            ),
            ListTile(
              title: Text(
                'SAVE20 - ₹20 off',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onTap: () {
                Navigator.pop(context);
                onApplyCoupon(20);
              },
            ),
            ListTile(
              title: Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showCouponSheet(context),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.ticket,
                  color: AppColors.redPrimary,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Apply Coupon Code',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.coins,
                color: Colors.amber[700],
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Use SuperCoins / Loyalty Points',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                  ),
                ),
              ),
              Switch(
                value: isSuperCoinsUsed,
                onChanged: onToggleSuperCoins,
                activeColor: AppColors.redPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

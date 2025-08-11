import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class PriceSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double vat;
  final double shipping;
  final double coinsUsed;
  final double discount;

  const PriceSummaryWidget({
    super.key,
    required this.subtotal,
    required this.vat,
    required this.shipping,
    this.coinsUsed = 0,
    this.discount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double total = subtotal + vat + shipping - discount - coinsUsed;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', subtotal),
          _buildRow('VAT', vat),
          _buildRow('Shipping fee', shipping),
          if (discount > 0) _buildRow('Discount', -discount, color: Colors.red),
          if (coinsUsed > 0)
            _buildRow('Coins Used', -coinsUsed, color: AppColors.redAccent),
          Divider(thickness: 1, height: 24.h),
          _buildRow(
            'Total',
            total,
            isBold: true,
            color: AppColors.greenColor,
            fontSize: 15.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
    double? fontSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: fontSize ?? 13.sp,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: fontSize ?? 13.sp,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

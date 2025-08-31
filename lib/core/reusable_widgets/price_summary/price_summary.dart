import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class PriceSummaryWidget extends StatelessWidget {
  final String itemName;
  // final String base;
  final String size;
  final double price;
  final double gst; // GST amount
  final int quantity;

  const PriceSummaryWidget({
    super.key,
    required this.itemName,
    // required this.base,
    required this.size,
    required this.price,
    required this.gst,
    this.quantity = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Item',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Price',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // SizedBox(height: 8.h),
          SizedBox(height: 8.h),

          Divider(thickness: 1, height: 24.h),
          // Product Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                quantity.toString(),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13.sp),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Text(
                      //   base,
                      //   style: TextStyle(
                      //     fontFamily: 'Poppins',
                      //     fontSize: 12.sp,
                      //     color: Colors.grey[700],
                      //   ),
                      // ),
                      Text(
                        size,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          Divider(thickness: 1, height: 24.h),

          SizedBox(height: 8.h),
          // Cart Row
          _buildRow('Cart', price),
          SizedBox(height: 4.h),

          // GST Row
          Text(
            'GST (15%) inc. in price',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),

          Divider(thickness: 1, height: 24.h),

          // Total Row
          _buildRow(
            'Total',
            price,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize ?? 13.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(
      4,
      (index) => {
        'orderId': '#ORD00${100 + index}',
        'date': '24 July 2025',
        'status': 'Delivered',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'Order',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: ' History',
                style: TextStyle(
                  color: AppColors.redAccent,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final item = orders[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.receipt,
                  color: Colors.black,
                  size: 16.sp,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['orderId']!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item['date']} - ${item['status']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 14.sp,
                  color: Colors.grey[500],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

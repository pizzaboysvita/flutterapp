import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = List.generate(
      4,
      (index) => {
        'title': 'Order Update',
        'desc': 'Your order #ORD00${200 + index} has been shipped.',
        'time': '1h ago',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'Notifi',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: 'cations',
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
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
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
                  FontAwesomeIcons.solidBell,
                  color: Colors.black,
                  size: 16.sp,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['desc']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item['time']!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

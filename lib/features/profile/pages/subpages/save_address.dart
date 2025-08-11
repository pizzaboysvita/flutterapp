import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class SavedAddressesView extends StatelessWidget {
  const SavedAddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    final addresses = List.generate(
      3,
      (index) => {
        'title': 'Home',
        'subtitle': 'Plot No. ${23 + index}, Street 5, Hyderabad',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: 'Saved',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: ' Address',
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
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final item = addresses[index];
          return _buildListTile(
            title: item['title']!,
            subtitle: item['subtitle']!,
            icon: FontAwesomeIcons.locationDot,
          );
        },
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 16.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.0.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.solidPenToSquare,
                  size: 16.sp,
                  color: AppColors.blackColor,
                ),
                onPressed: () {
                  
                },
              ),
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.solidTrashCan,
                  size: 16.sp,
                  color: AppColors.redAccent,
                ),
                onPressed: () {
                 
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

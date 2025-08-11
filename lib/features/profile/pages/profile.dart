import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Profile extends StatelessWidget {
  final ScrollController scrollController;
  const Profile({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text.rich(
          TextSpan(
            text: 'User',
            style: _textStyle(16.sp, FontWeight.w600),
            children: [
              TextSpan(
                text: ' Profile',
                style: TextStyle(color: AppColors.redAccent),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Icon(
            FontAwesomeIcons.powerOff,
            color: AppColors.redPrimary,
            size: 18.sp,
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(16.w),
        children: [
          _buildUserCard(context),
          SizedBox(height: 20.h),
          ..._buildProfileOptions(context),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.redPrimary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tori Greeno",
                  style: _textStyle(14.sp, FontWeight.w800, Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  "torri_greeno@gmail.com",
                  style: _textStyle(12.sp, FontWeight.normal, Colors.white60),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profileEdit),
            child: Icon(
              FontAwesomeIcons.edit,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfileOptions(BuildContext context) {
    final options = [
      _ProfileOption(
        FontAwesomeIcons.solidClock, // Filled (solid) variant
        "Order History",
        "View past orders and reorder quickly",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.orderHistory);
        },
      ),
      _ProfileOption(
        FontAwesomeIcons.locationDot, // Filled (solid)
        "Saved Addresses",
        "Manage your delivery locations",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.saveAddress);
        },
      ),
      _ProfileOption(
        FontAwesomeIcons.solidBell, // Filled
        "Notifications",
        "Order updates and exclusive offers",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.notifications);
        },
      ),
      _ProfileOption(
        FontAwesomeIcons.solidCreditCard, // Filled
        "Payment Methods",
        "Manage your saved cards",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.paymentMethods);
        },
      ),
      _ProfileOption(
        FontAwesomeIcons.solidCircleQuestion, // Filled support/help icon
        "Support",
        "Get help with orders or payments",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.support);
        },
      ),
      _ProfileOption(
        FontAwesomeIcons.shieldHalved, // Filled (solid) shield
        "Security Settings",
        "Manage password & login methods",
        ontap: () {
          Navigator.pushNamed(context, AppRoutes.securityAndSetting);
        },
      ),
    ];

    return options.map((e) => _buildListTile(e)).toList();
  }

  Widget _buildListTile(_ProfileOption option) {
    return InkWell(
      onTap: option.ontap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: option.title == 'Favorites'
                  ? AppColors.redAccent
                  : AppColors.blackColor,
              size: 20.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: _textStyle(14.sp, FontWeight.w500)),
                  SizedBox(height: 2.h),
                  Text(
                    option.subtitle,
                    style: _textStyle(
                      12.sp,
                      FontWeight.normal,
                      Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  TextStyle _textStyle(double size, FontWeight weight, [Color? color]) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color ?? Colors.black,
      fontFamily: 'Poppins',
    );
  }
}

class _ProfileOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback ontap;

  _ProfileOption(this.icon, this.title, this.subtitle, {required this.ontap});
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class IconAccordion extends StatefulWidget {
  const IconAccordion({super.key});

  @override
  State<IconAccordion> createState() => _IconAccordionState();
}

class _IconAccordionState extends State<IconAccordion> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isExpanded) ...[
                _buildIcon(FontAwesomeIcons.solidBell, () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                }, badgeCount: 3),
                SizedBox(width: 11.0.w),
                _buildIcon(FontAwesomeIcons.cartShopping, () {
                  Navigator.pushNamed(context, AppRoutes.cartView);
                }, badgeCount: 1),
                SizedBox(width: 12.0.w),
              ],
              _buildIcon(FontAwesomeIcons.solidUser, () {
                Navigator.pushNamed(context, AppRoutes.profile);
              }),
              _buildIcon(
                isExpanded
                    ? FontAwesomeIcons.chevronLeft
                    : FontAwesomeIcons.ellipsis,
                () => setState(() => isExpanded = !isExpanded),
                tooltip: isExpanded ? "Hide" : "More",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(
    IconData icon,
    VoidCallback onTap, {
    String? tooltip,
    int? badgeCount,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: tooltip ?? '',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 26.w,
                height: 25.h,
                child: Center(
                  child: FaIcon(icon, size: 16.sp, color: Colors.white),
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12.w,
                      minHeight: 12.h,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

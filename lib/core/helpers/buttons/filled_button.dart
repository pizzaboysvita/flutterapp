import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class LoadingFillButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressedAsync;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final bool isLoading;

  const LoadingFillButton({
    super.key,
    required this.text,
    this.onPressedAsync,
    this.backgroundColor = AppColors.redPrimary,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          onTap: isLoading
              ? null
              : () async {
                  if (onPressedAsync != null) {
                    await onPressedAsync!();
                  }
                },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      color: textColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          blurRadius: 20,
                          offset: Offset(0, 3),
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

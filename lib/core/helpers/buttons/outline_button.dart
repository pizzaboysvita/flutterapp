import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_bloc.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_event.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class LoadingOutlineButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Future<void> Function()? onPressedAsync;

  const LoadingOutlineButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressedAsync,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingButtonBloc, LoadingBtnState>(
      builder: (context, state) {
        final bool isLoading = state is ButtonLoading;

        return SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              8.r,
            ), // Same radius as fill button
            child: InkWell(
              onTap: isLoading
                  ? null
                  : () => context.read<LoadingButtonBloc>().add(
                      ButtonPressed(onPressedAsync: onPressedAsync),
                    ),
              borderRadius: BorderRadius.circular(8.r),
              splashColor: AppColors.blackColor.withOpacity(0.2),
              highlightColor: AppColors.blackColor.withOpacity(0.1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h), // Same padding
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r), // Same radius
                  border: Border.all(color: AppColors.blackColor, width: 1.5),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: AppColors.blackColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: AppColors.blackColor,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

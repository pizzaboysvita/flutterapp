import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_bloc.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_event.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

class LoadingFillButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressedAsync;

  const LoadingFillButton({super.key, required this.text, this.onPressedAsync});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingButtonBloc, LoadingBtnState>(
      builder: (context, state) {
        final bool isLoading = state is ButtonLoading;

        return SizedBox(
          width: double.infinity,
          child: Material(
            color: AppColors.redPrimary,
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: isLoading
                  ? null
                  : () => context.read<LoadingButtonBloc>().add(
                      ButtonPressed(onPressedAsync: onPressedAsync),
                    ),
              borderRadius: BorderRadius.circular(8.r),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                alignment: Alignment.center,
                child: isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          color: Colors.grey.shade200,
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
      },
    );
  }
}

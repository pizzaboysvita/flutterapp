import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_event.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_state.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';

class ServerTimeoutScreen extends StatelessWidget {
  final ServerTimeoutBloc bloc;

  const ServerTimeoutScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: BlocBuilder<ServerTimeoutBloc, ServerTimeoutState>(
                builder: (context, state) {
                  if (state is ServerTimeoutLoading) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200.w,
                          height: 200.h,
                          child: Lottie.asset(
                            LottieUrls.networkIssue,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "Retrying...",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 220.w,
                        height: 220.h,
                        child: Lottie.asset(
                          "assets/lottie/server_error.json",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Server Timeout",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "It’s taking too long to connect.\nPlease check your internet or try again.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 30.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          context.read<ServerTimeoutBloc>().add(
                            RetryRequestEvent(),
                          );
                        },
                        child: Text(
                          "Retry",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

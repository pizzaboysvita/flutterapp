import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_event.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_state.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerTimeoutScreen extends StatelessWidget {
  final ServerTimeoutBloc bloc;
  final String errorMessage;
  final VoidCallback onClose;

  const ServerTimeoutScreen({
    super.key,
    required this.bloc,
    required this.errorMessage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          onClose();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(backgroundColor: AppColors.scaffoldColorLight),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: BlocConsumer<ServerTimeoutBloc, ServerTimeoutState>(
                listener: (context, state) {
                  if (state is ServerTimeoutSuccess) {
                    onClose();
                    Navigator.of(context).pop(state.response);
                  }
                },
                builder: (context, state) {
                  if (state is ServerTimeoutLoading) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 0.4.sh,
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
                        height: 0.4.sh,
                        child: Lottie.asset(
                          LottieUrls.serverError,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // SizedBox(height: 20.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Oops! ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: "Server Error",
                              style: TextStyle(
                                color: AppColors.redAccent,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: 0.5.sw,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.redPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 4,
                            padding: EdgeInsets.symmetric(vertical: 0.h),
                          ),
                          onPressed: () {
                            context.read<ServerTimeoutBloc>().add(
                              RetryRequestEvent(),
                            );
                          },
                          icon: Icon(Icons.refresh, size: 20.sp),
                          label: Text(
                            "Try Again",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
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

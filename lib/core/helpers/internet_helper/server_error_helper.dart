import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_bloc.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_event.dart';
import 'package:pizza_boys/core/bloc/internet_check/server_error_state.dart';
import 'package:pizza_boys/core/helpers/api_client_helper.dart';
import '../../constant/app_colors.dart';
import '../../constant/lottie_urls.dart';
import '../../helpers/internet_helper/navigation_error.dart';
import '../../../routes/app_routes.dart';

class ServerTimeoutScreen extends StatefulWidget {
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
  State<ServerTimeoutScreen> createState() => _ServerTimeoutScreenState();
}

class _ServerTimeoutScreenState extends State<ServerTimeoutScreen> {
  @override
  void initState() {
    super.initState();
    _autoRetry();
  }

void _autoRetry() {
  int attempt = 0;
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (!mounted || attempt >= 3) {
      timer.cancel();
      return;
    }

    final hasInternet = await ApiClient.hasInternetConnection();
    if (!hasInternet) return;

    attempt++;
    widget.bloc.add(RetryRequestEvent());
  });
}



  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: WillPopScope(
        onWillPop: () async {
          widget.onClose();
          return true;
        },
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: BlocConsumer<ServerTimeoutBloc, ServerTimeoutState>(
                listener: (context, state) {
                  if (state is ServerTimeoutSuccess) {
    ApiClient.isShowingServerError = false; // reset before navigation
    widget.onClose();
    NavigatorService.navigatorKey.currentState
        ?.pushReplacementNamed(AppRoutes.splashScreen);
  }                },
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
                        Text(
                          "Retrying please wait...",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
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
                      SizedBox(height: 10.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Oops! ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: "Server Error",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.redAccent,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        widget.errorMessage,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          color: Colors.black87,
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
                          ),
                          onPressed: () {
                            widget.bloc.add(RetryRequestEvent());
                          },
                          icon: Icon(Icons.refresh, size: 20.sp),
                          label: Text(
                            "Try Again",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "If the problem persists, please check your internet connection or try again later.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
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

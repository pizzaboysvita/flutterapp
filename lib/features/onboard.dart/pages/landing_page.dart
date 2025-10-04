import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/helpers/device_helper.dart';
import 'package:pizza_boys/core/helpers/buttons/filled_button.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = DeviceHelper.textTheme(context);

    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.only(
          left: 0.w,
          right: 0.w,
          top: 0.h, // ensures status bar / notch is safe
          bottom: 0.h, // ensures home indicator is safe
        ),
        child: Stack(
          children: [
            Positioned(
              child: RepaintBoundary(
                child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageUrls.landingImage),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isPortrait = orientation == Orientation.portrait;
                      return Flex(
                        spacing: 12,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        direction: isPortrait ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            child: Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(
                                text: "PIZZA ",
                                style: textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isPortrait ? 20 : 40,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 20,
                                      offset: Offset(0, 3),
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                                children: [
                                  TextSpan(
                                    text: "BOYZ",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                              child: Column(
                                spacing: 20,
                                mainAxisAlignment: isPortrait
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Fresh Pizza Delivered Fast with Just One Click!",
                                    textAlign: TextAlign.center,
                                    style: textTheme.headlineSmall!.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20.sp,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 20,
                                          offset: Offset(0, 3),
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Top-quality pizzas across Auckland, \n order online for pickup or delivery!",
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyLarge!.copyWith(
                                      color: Colors.grey.shade200,
                                      fontSize: 15.sp,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 20,
                                          offset: Offset(0, 3),
                                          color: Colors.black45,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: LoadingFillButton(
                                      text: "Get Started",
                                      onPressedAsync: () async {
                                    
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.chooseStoreLocation,
                                          (route) =>
                                              false, // removes all previous routes
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

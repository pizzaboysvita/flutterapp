import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/helpers/buttons/filled_button.dart';
import 'package:pizza_boys/core/helpers/ui/snackbar_helper.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class GuestCheckout extends StatefulWidget {
  const GuestCheckout({super.key});

  @override
  State<GuestCheckout> createState() => _GuestCheckoutState();
}

class _GuestCheckoutState extends State<GuestCheckout> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0.h,
          backgroundColor: AppColors.blackColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 12.h),
                      _inputField("Email", emailController, isEmail: true),
                      SizedBox(height: 16.h),
                      _inputField(
                        "Phone Number",
                        phoneController,
                        isPhone: true,
                      ),
                      SizedBox(height: 24.h),

                      // ✅ Continue Button
                      LoadingFillButton(
                        text: "Continue",
                        isLoading: false,
                        onPressedAsync: () async {
                          // if (formKey.currentState!.validate()) {
                          //   await TokenStorage.setGuest(true);
                          //   await TokenStorage.saveGuestEmail(emailController.text);
                          //   await TokenStorage.saveGuestPhone(phoneController.text);

                          //   SnackbarHelper.green(context, "Proceeding as Guest!");

                          //   Navigator.pushNamedAndRemoveUntil(
                          //     context,
                          //     AppRoutes.home,
                          //     (route) => false,
                          //   );
                          // }
                        },
                      ),
                      SizedBox(height: 12.h),

                      Text(
                        "We’ll use this info to confirm your order.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Header Section
  Widget _headerSection() {
    return Stack(
      children: [
        ClipPath(
          clipper: BottomRightCurveClipper(),
          child: Container(
            width: 1.sw,
            color: AppColors.blackColor,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(ImageUrls.logoWhite, height: 30.h),
                SizedBox(height: 12.h),
                Text(
                  "Guest Checkout",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Enter your email and phone to continue\nas guest.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -32.w,
          bottom: -20.h,
          child: Image.asset(
            ImageUrls.heroImage,
            width: 160.w,
            height: 160.h,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  // 🔹 Input Field Widget
  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$hint is required";
        }
        if (isEmail &&
            !RegExp(
              r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
            ).hasMatch(value.trim())) {
          return "Enter a valid email";
        }
        if (isPhone && !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
          return "Enter a valid 10-digit phone number";
        }
        return null;
      },
      style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.redAccent, width: 1.5),
        ),
        errorStyle: TextStyle(fontSize: 12.sp, color: AppColors.redAccent),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_event.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0.h,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.blackColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: BottomRightCurveClipper(),
                  child: Container(
                    width: 1.sw,
                    color: AppColors.blackColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 28.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(ImageUrls.logoWhite, height: 30.h),
                        SizedBox(height: 12.h),
                        Text(
                          "Create Account!",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Sign up and get started with\ndelicious deals",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white70,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.white24,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned Lottie animation outside the ClipPath
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
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  _inputField("Full Name", _nameCtrl),
                  SizedBox(height: 16.h),
                  _inputField("Email", _emailCtrl),
                  SizedBox(height: 16.h),
                  _passwordField(),
                  SizedBox(height: 16.h),
                  _confirmPasswordField(),
                  SizedBox(height: 16.h),
                  _mainButton("Register", () {
                    Navigator.pushNamed(context, AppRoutes.checkOut);
                  }),
                  SizedBox(height: 18.h),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account?",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.blackColor,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: " Login",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppColors.redPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14.sp,
          fontFamily: 'Poppins',
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14.sp,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField() {
    return BlocBuilder<PsObscureBloc, PsObscureState>(
      builder: (context, state) {
        final isObscure = state is PsObscureValue ? state.obscure : true;
        return TextField(
          controller: _passwordCtrl,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
            labelStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                context.read<PsObscureBloc>().add(ObscureText());
              },
            ),
          ),
        );
      },
    );
  }

  Widget _confirmPasswordField() {
    return BlocBuilder<PsObscureBloc, PsObscureState>(
      builder: (context, state) {
        final isObscure = state is PsObscureValue ? state.obscure : true;
        return TextField(
          controller: _confirmPasswordCtrl,
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            hintStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
            labelStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14.sp,
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                context.read<PsObscureBloc>().add(ObscureText());
              },
            ),
          ),
        );
      },
    );
  }

  Widget _mainButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.redPrimary,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}

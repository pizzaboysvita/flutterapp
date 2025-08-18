import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_event.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0.h,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 30.h),
                        Image.asset(ImageUrls.logoWhite, height: 30.h),
                        SizedBox(height: 12.h),
                        Text(
                          "Login to Proceed!",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Please login to place your\ndelicious order",
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
                // Positioned image OUTSIDE of ClipPath and NOT inside
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
                  _inputField("Email", emailController),
                  SizedBox(height: 16.h),
                  _passwordField(),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        fillColor: WidgetStatePropertyAll(AppColors.blackColor),
                        onChanged: (v) {},
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            color: AppColors.redPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _mainButton("Login", () {
                    Navigator.pushNamed(context, AppRoutes.checkOut);
                  }),
                  SizedBox(height: 14.h),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.checkOut);
                      // or go to home screen if guest should browse without checkout
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45.h),
                      side: BorderSide(color: AppColors.blackColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.solidUser,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(width: 8.0.w),
                        Text(
                          "Continue as Guest",
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

                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.blackColor,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: " Register",
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

                  // Guest Login Button
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
          controller: passwordController,
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
              icon: isObscure
                  ? Icon(Icons.visibility_off)
                  : Icon(Icons.visibility),
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

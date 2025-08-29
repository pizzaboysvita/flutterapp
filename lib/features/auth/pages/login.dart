import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/data/repositories/auth/login_repo.dart';
import 'package:pizza_boys/features/auth/bloc/integration/login/login_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/integration/login/login_event.dart';
import 'package:pizza_boys/features/auth/bloc/integration/login/login_state.dart';
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
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(LoginRepo()),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0.h,
          backgroundColor: AppColors.blackColor,
        ),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.data["message"] ?? "Login Successful"),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to checkout/home page with token
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.chooseStoreLocation,
                arguments: {
                  "token": state.data["access_token"],
                  "user": state.data["user"],
                },
              );
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerSection(),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 12.h),
                          _inputField("Email", emailController, isEmail: true),
                          SizedBox(height: 16.h),
                          _passwordField(),
                          SizedBox(height: 12.h),

                          Row(
                            children: [
                              Checkbox(
                                value: true,
                                fillColor: WidgetStatePropertyAll(
                                  AppColors.blackColor,
                                ),
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

                          // 🔹 Login Button
                          _mainButton(
                            state is LoginLoading ? "Logging in..." : "Login",
                            () {
                              if (_formKey.currentState!.validate()) {
                                context.read<LoginBloc>().add(
                                  LoginButtonPressed(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                            isLoading: state is LoginLoading,
                          ),

                          SizedBox(height: 14.h),

                          // 🔹 Continue as Guest
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.chooseStoreLocation,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 45.h),
                              side: BorderSide(
                                color: AppColors.blackColor,
                                width: 1.5,
                              ),
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

                          // 🔹 Register Button
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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

  // 🔹 Input Field with validation
  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
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
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 🔹 Password Field with validation
  Widget _passwordField() {
    return BlocBuilder<PsObscureBloc, PsObscureState>(
      builder: (context, state) {
        final isObscure = state is PsObscureValue ? state.obscure : true;

        return TextFormField(
          controller: passwordController,
          obscureText: isObscure,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Password is required";
            }
            if (value.length < 6) {
              return "Password must be at least 6 characters";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Password",
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

  // 🔹 Main Button with loader
  Widget _mainButton(
    String text,
    VoidCallback onPressed, {
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.redPrimary,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
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

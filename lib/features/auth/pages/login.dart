import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pizza_boys/core/bloc/checkbox/login/login_checkbox_bloc.dart';
import 'package:pizza_boys/core/bloc/checkbox/login/login_checkbox_event.dart';
import 'package:pizza_boys/core/bloc/checkbox/login/login_checkbox_state.dart';
import 'package:pizza_boys/core/bloc/loading_button/loading_button_bloc.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/helpers/buttons/filled_button.dart';
import 'package:pizza_boys/core/helpers/buttons/outline_button.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
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
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    if (args != null) {
      emailController.text = args['prefillEmail'] ?? '';
      passwordController.text = args['prefillPassword'] ?? '';
    }
    return BlocProvider(
      create: (_) => LoginBloc(LoginRepo()),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                    backgroundColor: AppColors.redPrimary,
                  ),
                );

                // Delay navigation until after the current frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.chooseStoreLocation,
                    arguments: {
                      "token": state.data["access_token"],
                      "user": state.data["user"],
                    },
                  );
                });
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
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 12.h),
                            _inputField(
                              "Email",
                              emailController,
                              isEmail: true,
                            ),
                            SizedBox(height: 16.h),
                            _passwordField(),
                            SizedBox(height: 6.h),

                            // SizedBox(height: 12.h),
                            BlocBuilder<LoginCheckboxBloc, LoginCheckboxState>(
                              builder: (context, settingsState) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: settingsState.acceptTerms,
                                      fillColor:
                                          MaterialStateProperty.resolveWith<
                                            Color
                                          >((states) {
                                            if (states.contains(
                                              MaterialState.selected,
                                            )) {
                                              return AppColors
                                                  .blackColor; // Fill color when checked
                                            }
                                            return Colors
                                                .white; // Fill color when unchecked
                                          }),
                                      checkColor: AppColors
                                          .whiteColor, // Color of the check mark
                                      side: MaterialStateBorderSide.resolveWith((
                                        states,
                                      ) {
                                        return BorderSide(
                                          color: AppColors
                                              .blackColor, // Border color always black
                                          width: 1.5,
                                        );
                                      }),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ), // Rounded corners
                                      ),
                                      onChanged: (v) {
                                        context.read<LoginCheckboxBloc>().add(
                                          ToggleAcceptTerms(),
                                        );
                                      },
                                    ),

                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => context
                                            .read<LoginCheckboxBloc>()
                                            .add(ToggleAcceptTerms()),
                                        child: Text.rich(
                                          TextSpan(
                                            text: "I agree to the ",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.blackColor,
                                              fontFamily: 'Poppins',
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Terms & Conditions",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: 16.h),

                            BlocProvider(
                              create: (_) => LoadingButtonBloc(),
                              child: LoadingFillButton(
                                text: "Login",
                                onPressedAsync: () async {
                                  if (formKey.currentState!.validate()) {
                                    context.read<LoginBloc>().add(
                                      LoginButtonPressed(
                                        emailController.text.trim(),
                                        passwordController.text.trim(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),

                            SizedBox(height: 14.h),

                            LoadingOutlineButton(
                              text: "Continue as Guest",
                              icon: FontAwesomeIcons.solidUser,
                              onPressedAsync: () async {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.chooseStoreLocation,
                                );
                              },
                            ),

                            SizedBox(height: 12.h),

                            InkWell(
                              borderRadius: BorderRadius.circular(8.r),
                              splashColor: AppColors.redAccent.withOpacity(
                                0.3,
                              ), // More visible splash
                              highlightColor: AppColors.redAccent.withOpacity(
                                0.1,
                              ), // More visible highlight
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                  horizontal: 16.w,
                                ),
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
                                          color: AppColors.redAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
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
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      autofillHints: isEmail ? [AutofillHints.email] : null,
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
      style: TextStyle(fontSize: 14.sp),
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

  // 🔹 Password Field with validation
  Widget _passwordField() {
    return BlocBuilder<PsObscureBloc, PsObscureState>(
      builder: (context, state) {
        final isObscure = state is PsObscureValue ? state.obscure : false;

        return TextFormField(
          controller: passwordController,
          obscureText: isObscure,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: [AutofillHints.password],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Password is required";
            }
            if (value.trim().length < 6) {
              return "Password must be at least 6 characters";
            }
            return null;
          },
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(fontSize: 14.sp, color: Colors.black),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
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
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: isObscure ? Colors.grey.shade600 : AppColors.redPrimary,
              ),
              onPressed: () {
                context.read<PsObscureBloc>().add(ObscureText());
              },
              tooltip: isObscure ? 'Show password' : 'Hide password',
            ),
          ),
        );
      },
    );
  }
}

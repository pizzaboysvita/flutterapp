import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/helpers/device_helper.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/core/utils/app_utils.dart';
import 'package:pizza_boys/core/validations/validation_rules.dart';
import 'package:pizza_boys/data/repositories/auth/login_repo.dart';
import 'package:pizza_boys/features/auth/bloc/integration/login/login_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/integration/login/login_event.dart';
import 'package:pizza_boys/features/auth/bloc/integration/login/login_state.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_event.dart';
import 'package:pizza_boys/features/auth/bloc/ui/ps_obscure_state.dart';
import 'package:pizza_boys/features/widgets/controls/form_input.dart';
import 'package:pizza_boys/features/widgets/controls/text_rich_button.dart';
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

  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = DeviceHelper.textTheme(context);
    final isPortrait = DeviceHelper.isPortraitOrientation(context);
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
              AppUtils.showSnackbar(
                context,
                state.data["message"] ?? "Login Successful",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.data["message"] ?? "Login Successful"),
                  backgroundColor: Colors.green,
                ),
              );
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
                  _headerSection(textTheme, isPortrait),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 12.h),
                          _formInputField(
                            hint: "Email",
                            controller: emailController,
                            isEmail: true,
                          ),
                          SizedBox(height: 16.h),
                          _passwordField(),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Checkbox(
                                value: true,
                                fillColor: const WidgetStatePropertyAll(
                                  AppColors.blackColor,
                                ),
                                onChanged: (v) {},
                              ),
                              Text(
                                "Remember me",
                                style: textTheme.titleSmall!.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forgot Password?",
                                  style: textTheme.titleSmall!.copyWith(
                                    color: AppColors.redPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _mainButton(
                            textTheme,
                            state is LoginLoading ? "Logging in..." : "Login",
                            () {
                              setState(() {
                                _submitted = true;
                              });

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
                          SizedBox(
                            width: double.maxFinite,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.chooseStoreLocation,
                                );
                              },
                              icon: Icon(
                                FontAwesomeIcons.solidUser,
                                color: AppColors.blackColor,
                              ),
                              label: Text(
                                "Continue as Guest",
                                style: textTheme.titleMedium,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextRichButton(
                            normalText: "Don't have an account? ",
                            actionText: "Register",
                            onActionTap: () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
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

  Widget _headerSection(TextTheme textTheme, bool isPortrait) {
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
                  style: textTheme.titleLarge!.copyWith(color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Please login to place your\ndelicious order",
                  style: textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: isPortrait ? -3 : -3,
          bottom: isPortrait ? -5 : 8,
          child: Image.asset(
            ImageUrls.heroImage,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _formInputField({
    required String hint,
    required TextEditingController controller,
    bool isEmail = false,
  }) {
    return FormInput(
      placeHolderText: hint,
      isRequired: true,
      initialValue: controller.text,
      validationRules: isEmail ? [ValidationRules.Email] : null,
      onChanged: (value) => controller.text = value,
      prefixIcon: Icon(Icons.email),
      showPrefixIcon: true,
      autoValidate: _submitted,
    );
  }

  Widget _passwordField() {
    return BlocBuilder<PsObscureBloc, PsObscureState>(
      builder: (context, state) {
        final isObscure = state is PsObscureValue ? state.obscure : true;

        return FormInput(
          showPrefixIcon: true,
          prefixIcon: Icon(Icons.lock),
          placeHolderText: "Password",
          isRequired: true,
          isVisible: isObscure,
          validationRules: [ValidationRules.Password],
          onChanged: (value) => passwordController.text = value,
          suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              context.read<PsObscureBloc>().add(ObscureText());
            },
          ),
          autoValidate: _submitted,
        );
      },
    );
  }

  Widget _mainButton(
    TextTheme textTheme,
    String text,
    VoidCallback onPressed, {
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(text),
      ),
    );
  }
}

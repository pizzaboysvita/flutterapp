import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/features/auth/bloc/integration/register/register_bloc.dart';
import 'package:pizza_boys/features/auth/bloc/integration/register/register_event.dart';
import 'package:pizza_boys/features/auth/bloc/integration/register/register_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("✅ Registered successfully")));
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login, // replace with your login route
            (route) => false,
          );
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: AppColors.blackColor,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _headerSection(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🔹 Profile Image Picker with guidance
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 45.r,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : null,
                                  child: _image == null
                                      ? Icon(
                                          Icons.camera_alt,
                                          size: 32.r,
                                          color: Colors.grey.shade500,
                                        )
                                      : null,
                                ),
                                if (_image == null)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 12.r,
                                      backgroundColor: AppColors.redAccent,
                                      child: Icon(
                                        Icons.add,
                                        size: 16.r,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Upload your profile photo",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // 🔹 Name Fields in one row for better UX
                          Row(
                            children: [
                              Expanded(
                                child: _field("First Name", _firstNameCtrl),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: _field("Last Name", _lastNameCtrl),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          _field(
                            "Phone Number",
                            _phoneCtrl,
                            keyboard: TextInputType.phone,
                          ),
                          SizedBox(height: 10.h),

                          _field("Email", emailCtrl, isEmail: true),
                          SizedBox(height: 10.h),

                          _field(
                            "Password",
                            passwordCtrl,
                            obscure: true,
                            isPassword: true,
                          ),
                          SizedBox(height: 10.h),

                          // 🔹 Address block
                          _field("Address", _addressCtrl),
                          SizedBox(height: 10.h),
                          _field("Country", _countryCtrl),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Expanded(child: _field("State", _stateCtrl)),
                              SizedBox(width: 10.w),
                              Expanded(child: _field("City", _cityCtrl)),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          _field(
                            "Pin Code",
                            _pinCtrl,
                            keyboard: TextInputType.number,
                          ),
                          SizedBox(height: 24.h),

                          // 🔹 Register Button with loading
                          BlocBuilder<RegisterBloc, RegisterState>(
                            builder: (context, state) {
                              final isLoading = state is RegisterLoading;

                              return SizedBox(
                                width: double.infinity,
                                child: Material(
                                  color: AppColors.redPrimary,
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: InkWell(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              context.read<RegisterBloc>().add(
                                                SubmitRegister(
                                                  firstName: _firstNameCtrl.text
                                                      .trim(),
                                                  lastName: _lastNameCtrl.text
                                                      .trim(),
                                                  phone: _phoneCtrl.text.trim(),
                                                  email: emailCtrl.text.trim(),
                                                  password: passwordCtrl.text
                                                      .trim(),
                                                  address: _addressCtrl.text
                                                      .trim(),
                                                  country: _countryCtrl.text
                                                      .trim(),
                                                  state: _stateCtrl.text.trim(),
                                                  city: _cityCtrl.text.trim(),
                                                  pinCode:
                                                      int.tryParse(
                                                        _pinCtrl.text.trim(),
                                                      ) ??
                                                      0,
                                                  imageFile: _image,
                                                ),
                                              );
                                            }
                                          },
                                    borderRadius: BorderRadius.circular(8.r),
                                    splashColor: Colors.white.withOpacity(0.3),
                                    highlightColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      alignment: Alignment.center,
                                      child: isLoading
                                          ? SizedBox(
                                              width: 24.w,
                                              height: 24.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                            )
                                          : Text(
                                              "Register",
                                              style: TextStyle(
                                                color: Colors.grey.shade200,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                shadows: const [
                                                  Shadow(
                                                    blurRadius: 20,
                                                    offset: Offset(0, 3),
                                                    color: Colors.black45,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),

                          // 🔹 Already have an account? Login
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            splashColor: AppColors.redAccent.withOpacity(0.2),
                            highlightColor: AppColors.redAccent.withOpacity(
                              0.1,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text.rich(
                                TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " Login",
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
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 Header section like login
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
                  "Create an Account!",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Register now to enjoy your\nfavorite pizza anytime",
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

  // 🔹 Custom TextFormField with validation
  Widget _field(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    bool isEmail = false,
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        maxLength: maxLength,
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
          if (isPassword && value.length < 6) {
            return "Password must be at least 6 characters";
          }
          return null;
        },
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
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
      ),
    );
  }
}

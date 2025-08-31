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
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
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
          ).showSnackBar(SnackBar(content: Text("❌ Error: ${state.error}")));
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
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 🔹 Profile Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : null,
                            child: _image == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        _field("First Name", _firstNameCtrl),
                        _field("Last Name", _lastNameCtrl),
                        _field(
                          "Phone Number",
                          _phoneCtrl,
                          keyboard: TextInputType.phone,
                        ),
                        _field("Email", _emailCtrl, isEmail: true),
                        _field(
                          "Password",
                          _passwordCtrl,
                          obscure: true,
                          isPassword: true,
                        ),
                        _field("Address", _addressCtrl),
                        _field("Country", _countryCtrl),
                        _field("State", _stateCtrl),
                        _field("City", _cityCtrl),
                        _field(
                          "Pin Code",
                          _pinCtrl,
                          keyboard: TextInputType.number,
                        ),

                        SizedBox(height: 16.h),

                        // 🔹 Register Button
                        _mainButton(
                          state is RegisterLoading
                              ? "Registering..."
                              : "Register",
                          () {
                            if (_formKey.currentState!.validate()) {
                              context.read<RegisterBloc>().add(
                                SubmitRegister(
                                  firstName: _firstNameCtrl.text.trim(),
                                  lastName: _lastNameCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  password: _passwordCtrl.text.trim(),
                                  address: _addressCtrl.text.trim(),
                                  country: _countryCtrl.text.trim(),
                                  state: _stateCtrl.text.trim(),
                                  city: _cityCtrl.text.trim(),
                                  pinCode:
                                      int.tryParse(_pinCtrl.text.trim()) ?? 0,
                                  imageFile: _image,
                                ),
                              );
                            }
                          },
                          isLoading: state is RegisterLoading,
                        ),

                        SizedBox(height: 12.h),

                        // 🔹 Already have account? Login
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
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
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
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
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔹 Main Button (same as login)
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

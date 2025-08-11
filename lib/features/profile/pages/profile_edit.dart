import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';

class ProfileEdit extends StatelessWidget {
  const ProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: "Tori Greeno");
    final emailController = TextEditingController(
      text: "torri_greeno@gmail.com",
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text.rich(
          TextSpan(
            text: 'Modify',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: ' Profile',
                style: TextStyle(
                  color: AppColors.redAccent,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _buildProfilePicture(),
            SizedBox(height: 24.h),
            _inputField('Name', nameController),
            SizedBox(height: 24.h),

            _inputField('Email', emailController),
            SizedBox(height: 32.h),
            _mainButton('Save', () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 45.r,
          backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
        ),
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.redPrimary,
          ),
          child: Icon(FontAwesomeIcons.pen, size: 12.sp, color: Colors.white),
        ),
      ],
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
}

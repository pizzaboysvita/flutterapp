import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/features/profile/bloc/user_info_cubit.dart';
import 'package:pizza_boys/data/models/user/profile_model.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers after first frame to ensure provider exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserCubit>().state;
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      emailController.text = user.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserModel>(
      builder: (context, user) {
        return Scaffold(
          appBar: AppBar(
            title: Text.rich(
              TextSpan(
                text: 'Modify',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                    text: ' Profile',
                    style: TextStyle(color: AppColors.redAccent),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildProfilePicture(user),
                SizedBox(height: 24.h),
                _inputField("First Name", firstNameController),
                SizedBox(height: 16.h),
                _inputField("Last Name", lastNameController),
                SizedBox(height: 16.h),
                _inputField("Email", emailController),
                SizedBox(height: 30.h),
                ElevatedButton(
                  onPressed: () => _saveProfile(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture(UserModel user) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 45.r,
          backgroundImage: selectedImage != null
              ? FileImage(selectedImage!)
              : NetworkImage(
                      user.profile.isNotEmpty
                          ? user.profile
                          : "https://i.pravatar.cc/300",
                    )
                    as ImageProvider,
        ),

        /// ✏️ Edit / Loading Button
        GestureDetector(
          onTap: _isPickingImage ? null : _pickImage,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.redPrimary,
            ),

            child: _isPickingImage
                ? SizedBox(
                    width: 14.sp,
                    height: 14.sp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(FontAwesomeIcons.pen, size: 12.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // prevent multiple calls

    _isPickingImage = true;

    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // optional optimization
      );

      if (picked != null && mounted) {
        setState(() {
          selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _saveProfile(UserModel user) async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First & Last name required")),
      );
      return;
    }

    try {
      await context.read<UserCubit>().updateUser(
        fields: {
          "first_name": firstNameController.text.trim(),
          "last_name": lastNameController.text.trim(),
          "email": emailController.text.trim(),
        },
        image: selectedImage,
      );

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      // Pop back after update
      Navigator.pop(context);
    } on Exception catch (e) {
      // Only show true errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtils {
  AppUtils._();

  static Future<bool> checkInternet() async {
    final connectionResult = await Connectivity().checkConnectivity();
    return connectionResult != ConnectivityResult.none;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static void showSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.redPrimary,
        duration: duration,
      ),
    );
  }

  static Future<T?> showDialogBox<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? buttonAction,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: buttonAction ?? () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  static Future<T?> showModernDialog<T>({
    required BuildContext context,
    required String title,
    String? button1Text,
    String? button2Text,
    VoidCallback? button1Action,
    VoidCallback? button2Action,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 8),
        content: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (button1Text != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            button1Action ?? () => Navigator.pop(context),
                        child: Text(button1Text),
                      ),
                    ),
                  if (button1Text != null && button2Text != null)
                    const SizedBox(width: 24),
                  if (button2Text != null)
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            button2Action ?? () => Navigator.pop(context),
                        child: Text(button2Text),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showImagePicker({
    required BuildContext context,
    required void Function(XFile? photo, String? source) onPhotoButtonClicked,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              ListTile(
                onTap: () async {
                  try {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      maxHeight: 1000,
                      maxWidth: 1000,
                    );
                    onPhotoButtonClicked(image, "Camera");
                    Navigator.pop(context);
                  } catch (e) {
                    log("Camera error: $e");
                  }
                },
                title: const Text("Take Photo"),
                trailing: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.redPrimary,
                ),
              ),
              const Divider(),
              ListTile(
                onTap: () async {
                  try {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxHeight: 1000,
                      maxWidth: 1000,
                    );
                    onPhotoButtonClicked(image, "Gallery");
                    Navigator.pop(context);
                  } catch (e) {
                    log("Gallery error: $e");
                  }
                },
                title: const Text("Photo Library"),
                trailing: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.redPrimary,
                ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

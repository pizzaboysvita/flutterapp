import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';

import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';

class OfferPopup extends StatelessWidget {
  final String title;
  final String description;
  final String? lottiePath; // optional Lottie
  final VoidCallback onGotIt;
  final VoidCallback onClose;

  const OfferPopup({
    super.key,
    required this.title,
    required this.description,
    this.lottiePath,
    required this.onGotIt,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (lottiePath != null)
                    SizedBox(
                      width: double.infinity,
                      height: 160.h,
                      child: Lottie.asset(lottiePath!, fit: BoxFit.contain),
                    ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: AppColors.redAccent,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onGotIt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Got It!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: onClose,
                child: CircleAvatar(
                  radius: 14.r,
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Correct Sequential Function
// ✅ Correct Sequential Function with debug logs
Future<void> showDynamicPopups(
  BuildContext context,
  List<Map<String, dynamic>> promos,
) async {
  print("🔹 showDynamicPopups called with ${promos.length} promos");

  if (promos.isEmpty) {
    print("🔹 No promos available, returning early");
    return;
  }

  for (int i = 0; i < promos.length; i++) {
    final promo = promos[i];
    print(
      "🔹 Showing promo ${i + 1}/${promos.length}: ${promo["promo_name"]} (${promo["promo_code"]})",
    );

  await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => Dialog(
    backgroundColor: Colors.white,
    insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 0.8.sh),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (LottieUrls.promoCode != null)
                  SizedBox(
                    width: double.infinity,
                    height: 160.h,
                    child: Lottie.asset(LottieUrls.promoCode, fit: BoxFit.contain),
                  ),
                SizedBox(height: 16.h),
                Text(
                  promo["promo_name"] ?? "Special Offer",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    color: AppColors.redAccent,
                  ),
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: SingleChildScrollView(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                        ),
                        children: [
                          const TextSpan(text: "Use code "),
                          TextSpan(
                            text: promo["promo_code"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                " to get \$${promo["fixed_discount"]} OFF.\nMin order: \$${promo["min_order"]}",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print("🔹 Promo ${promo["promo_name"]} 'Got It' pressed");
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Got It!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: () {
                print("🔹 Promo ${promo["promo_name"]} closed");
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                radius: 14.r,
                backgroundColor: Colors.black26,
                child: Icon(Icons.close, size: 16.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

    print("🔹 Promo ${promo["promo_name"]} dialog closed");
    // No artificial delay here — dialogs show immediately one after another
  }
}

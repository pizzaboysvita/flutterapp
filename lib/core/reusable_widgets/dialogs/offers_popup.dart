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
                      child: Lottie.asset(
                        lottiePath!,
                        fit: BoxFit.contain,
                      ),
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
void showDynamicPopups(BuildContext context, List<Map<String, dynamic>> promos) {
  if (promos.isEmpty) return; // no data, don't show anything

  void showNext(int index) {
    if (index >= promos.length) return;
    final promo = promos[index];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OfferPopup(
        title: promo["promo_name"] ?? "Special Offer",
        description:
            "Use code ${promo["promo_code"]} to get ₹${promo["fixed_discount"]} OFF.\nMin order: ₹${promo["min_order"]}",
        lottiePath: LottieUrls.promoCode, // default Lottie
        onGotIt: () {
          Navigator.of(context).pop();
          if (index + 1 < promos.length) {
            showNext(index + 1);
          }
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  showNext(0);
}

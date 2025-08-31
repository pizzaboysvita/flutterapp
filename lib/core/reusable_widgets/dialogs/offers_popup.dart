import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';

class OfferPopup extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onGotIt;
  final VoidCallback onClose;

  const OfferPopup({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onGotIt,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SizedBox(
        width: 1.sw,
        height: 320.h,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: 160.h,
                      fit: BoxFit.cover,
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
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  SizedBox(
                    width: double.infinity,
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: onGotIt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Got It!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
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
void showSequentialPopups(BuildContext context) {
  final List<Map<String, String>> popups = [
    {
      'title': "Large Trio Combo – Just \$50!",
      'description': "3 large pizzas for just \$50 ",
      'image': ImageUrls.comboOffer,
    },
    {
      'title': "Up to 40% OFF!",
      'description': "Top flavours, limited time – don’t miss out!",
      'image': ImageUrls.discountOffer,
    },
  ];

  void showNext(int index) {
    if (index >= popups.length) return;
    final item = popups[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OfferPopup(
        title: item['title']!,
        description: item['description']!,
        imagePath: item['image']!,
        onGotIt: () {
          Navigator.of(context).pop();
          if (index + 1 < popups.length) {
            showNext(index + 1);
          }
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  showNext(0);
}

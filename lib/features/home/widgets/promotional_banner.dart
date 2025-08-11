import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_event.dart';
import 'package:pizza_boys/features/home/bloc/ui/banner/banner_state.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final promoImages = [
      ImageUrls.banner1,
      ImageUrls.banner2,
      ImageUrls.banner3,
      ImageUrls.banner4,
    ];

    return BlocBuilder<BannerCarouselBloc, BannerCarouselState>(
      builder: (context, state) {
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 100.h,
                autoPlay: true,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  context.read<BannerCarouselBloc>().add(
                    BannerPageChanged(index),
                  );
                },
              ),
              items: promoImages.map((imagePath) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: 52.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: promoImages.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  height: 5.h,
                  width: state.currentIndex == entry.key ? 14.w : 6.w,
                  decoration: BoxDecoration(
                    color: state.currentIndex == entry.key
                        ? AppColors.redAccent
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

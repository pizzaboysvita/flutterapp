import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/shapes/hero_bottomcurve.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_state.dart';
import 'package:pizza_boys/features/home/bloc/ui/carosel_text/carosel_bloc.dart';
import 'package:pizza_boys/features/home/bloc/ui/carosel_text/carosel_event.dart';
import 'package:pizza_boys/features/home/bloc/ui/carosel_text/carosel_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> textList = [
      {
        'title': "Vita Tech made a Pizza.\nGet it now.",
        'subtitle': "limited-edition",
      },
      {
        'title': "Order your favorite Pizza\nat your doorstep.",
        'subtitle': "Fast & Hot Delivery",
      },
      {
        'title': "Special discounts\nthis weekend only!",
        'subtitle': "Hurry up!",
      },
    ];
    return Stack(
      children: [
        // Background with clipped shape
        ClipPath(
          clipper: BottomRightCurveClipper(),
          child: Container(
            width: 1.sw,
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocProvider(
                  create: (_) =>
                      CarouselTextBloc(textList.length)..add(StartCarousel()),
                  child: BlocBuilder<CarouselTextBloc, CarouselTextState>(
                    builder: (context, state) {
                      final item = textList[state.currentIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.centerLeft,
                                children: <Widget>[
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            child: Column(
                              key: ValueKey(item['title']),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    shadows: [
                                      Shadow(
                                        color: Colors.white24,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  item['subtitle']!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white70,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white24,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Row(
                            children: List.generate(
                              textList.length,
                              (index) => _buildDot(index == state.currentIndex),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Positioned image OUTSIDE of ClipPath and NOT inside
        Positioned(
          right: -32.w,
          bottom: -26.h,
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

  Widget _buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      width: isActive ? 10.w : 6.w,
      height: isActive ? 10.h : 6.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.redAccent : Colors.white30,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

//Category of Pizzas
// Define pastel colors list
final List<Color> categoryColors = [
  AppColors.categoryOrange, // Light Orange
  AppColors.categoryGreen, // Light Green
  AppColors.categoryYellow, // Light Yellow
  AppColors.categoryPink, // Soft Pink
];

class PizzaCategoriesRow extends StatelessWidget {
  final int? selectedCategoryId;
  final ValueChanged<int>? onCategorySelected;

  const PizzaCategoriesRow({
    super.key,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 5, // Number of shimmer placeholders
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => Column(
                children: [
                  // Circle/Image shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Text shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 60.w,
                      height: 12.h,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is CategoryLoaded) {
          return SizedBox(
            height: 100.h,
            child: Builder(
              builder: (context) {
                // copy categories list
                final categories = List.of(state.categories);

                // find the special category
                final specialIndex = categories.indexWhere(
                  (c) => c.id == 108 || c.name.toLowerCase() == "specials",
                );

                // if found, move it to the front
                if (specialIndex != -1) {
                  final special = categories.removeAt(specialIndex);
                  categories.insert(0, special);
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    // final bgColor = categoryColors[index % categoryColors.length];

                    final isActive = item.id == selectedCategoryId;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.categoryPizzaDetails,
                          arguments: {'categoryId': item.id},
                        );
                        print(item.id);
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            width: 50.w,
                            height: 50.w,
                            // decoration: BoxDecoration(
                            //   color: isActive ? Colors.orangeAccent : bgColor,
                            //   borderRadius: BorderRadius.circular(12.r),
                            //   border: isActive
                            //       ? Border.all(color: Colors.deepOrange, width: 2)
                            //       : null,
                            // ),
                            // padding: EdgeInsets.all(8.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.r),
                              child: CachedNetworkImage(
                                imageUrl: item.categoryImage.isNotEmpty
                                    ? item.categoryImage
                                    : "https://via.placeholder.com/150",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 80.w,
                            child: Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.sp,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.deepOrange
                                    : Colors.black87,
                              ),
                              // maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is CategoryError) {
          return Center(child: Text(state.message));
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

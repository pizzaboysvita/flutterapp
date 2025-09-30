import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_state.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_event.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class PopularPicks extends StatelessWidget {
  const PopularPicks({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Trigger fetching when widget builds
    context.read<DishBloc>().add(GetAllDishesEvent(categoryId: 1));

    final List<Map<String, dynamic>> fallbackData = [
      {
        'name': 'Pepperoni Classic',
        'price': 12.99,
        'image': ImageUrls.catergoryPizza,
        'rating': 4.5,
      },
      {
        'name': 'BBQ Chicken',
        'price': 14.99,
        'image': ImageUrls.catergoryPizza,
        'rating': 4.2,
      },
      {
        'name': 'Veggie Delight',
        'price': 10.49,
        'image': ImageUrls.catergoryPizza,
        'rating': 4.0,
      },
      {
        'name': 'Cheese Burst',
        'price': 11.99,
        'image': ImageUrls.catergoryPizza,
        'rating': 4.8,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Picks',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          /// BlocBuilder for API data
          BlocBuilder<DishBloc, DishState>(
            builder: (context, state) {
              if (state is DishLoading) {
                /// ✅ Show shimmer grid placeholder (4 items → 2x2)
                return GridView.builder(
                  itemCount: 4, // 2x2 grid
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// Image placeholder
                            Container(
                              height: 105.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),

                            /// Name placeholder
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 12.h,
                                    width: 60.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 6.h),

                                  /// Rating + price placeholder
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 10.h,
                                        width: 30.w,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10.w),
                                      Container(
                                        height: 10.h,
                                        width: 40.w,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),

                                  /// Button placeholder
                                  Container(
                                    height: 32.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (state is DishLoaded) {
                final List<DishModel> dishes = state.dishes;
                return GridView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    final fallback = fallbackData[index % fallbackData.length];

                    final name = (dish.name.isNotEmpty)
                        ? dish.name
                        : fallback['name'];
                    final price = (dish.price != 0.0)
                        ? dish.price
                        : fallback['price'];
                    final rating = (dish.rating != 0.0)
                        ? dish.rating
                        : fallback['rating'];

                    /// ✅ Safe Image with fallback placeholder
                    final safeImage = (dish.imageUrl.isNotEmpty)
                        ? dish.imageUrl
                        : "https://wallpapers.com/images/hd/error-placeholder-image-2e1q6z01rfep95v0.jpg";

                    return GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12.r),
                                  ),
                                  child: CachedNetworkImage(
                                    height: 105.h,
                                    width: double.infinity,
                                    imageUrl: safeImage,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 500, // Resize width
                                    memCacheHeight: 300, // Resize height
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            color: Colors.white,
                                            width: double.infinity,
                                            height: 100.h,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.broken_image,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),

                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Icon(
                                          //   Icons.star,
                                          //   color: Colors.amber,
                                          //   size: 12.sp,
                                          // ),
                                          // SizedBox(width: 2.w),
                                          // Text(
                                          //   "$",
                                          //   style: TextStyle(
                                          //     fontSize: 10.sp,
                                          //     fontWeight: FontWeight.w500,
                                          //   ),
                                          // ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            "\$$price",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.greenColor,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(height: 4.h),
                                      // Text(
                                      //   "2 Coupons • Upto 30% off",
                                      //   style: TextStyle(
                                      //     fontSize: 9.sp,
                                      //     color: Colors.black54,
                                      //   ),
                                      // ),
                                      SizedBox(height: 6.h),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 32.h,
                                        child: Material(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient:
                                                  AppColors.buttonGradient,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              onTap: () {
                                                // ✅ Step 4: Dispatch Reset before navigation
                                                context
                                                    .read<PizzaDetailsBloc>()
                                                    .add(
                                                      ResetPizzaDetailsEvent(),
                                                    );

                                                // ✅ Then navigate to PizzaDetailsView with dishId
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.pizzaDetails,
                                                  arguments: dish
                                                      .id, // pass correct id
                                                );

                                                print(
                                                  '👉 Passing Selected Dish ID: ${dish.id}',
                                                );
                                              },

                                              child: Center(
                                                child: Text(
                                                  'Add to Cart',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Top Choice Tag
                          name == 'Hawaiian Pizza'
                              ? Positioned(
                                  top: 0.h,
                                  left: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryBlack(context),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.r),
                                        bottomRight: Radius.circular(8.r),
                                      ),
                                    ),
                                    child: Text(
                                      'Top Choice',
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),

                          /// Favorite Icon
                          Positioned(
                            top: 0.h,
                            right: 0.w,
                            child: BlocBuilder<FavoriteBloc, FavoriteState>(
                              builder: (context, state) {
                                bool isFavorite = false;

                                if (state is FavoriteLoaded) {
                                  isFavorite = state.favorites.any(
                                    (d) => d.id == dish.id,
                                  );
                                }

                                return IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: AppColors.redPrimary,
                                  ),
                                  onPressed: () {
                                    if (isFavorite) {
                                      if (dish.wishlistId != null) {
                                        context.read<FavoriteBloc>().add(
                                          RemoveFromFavoriteEvent(
                                            dishId: dish.id,
                                            wishlistId: dish.wishlistId,
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Removed from Favorites!",
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Cannot remove: wishlistId is missing!",
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      context.read<FavoriteBloc>().add(
                                        AddToFavoriteEvent(dish),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "❤️ Added to Favorites!",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (state is DishError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    // // ✅ Trigger fetch event when the view is loaded
    // Future.microtask(() {
    //   context.read<FavoriteBloc>().add(FetchWishlistEvent());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "My",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: " Whishlist",
                style: TextStyle(
                  color: AppColors.redAccent,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state is FavoriteLoading) {
              return const Center(child: LottieLoader());
            } else if (state is FavoriteLoaded) {
              if (state.favorites.isEmpty) {
                return const Center(child: Text("No favorites yet ❤️"));
              }

              // Group by dish id
              final groupedDishes = <int, List<DishModel>>{};
              for (var dish in state.favorites) {
                groupedDishes.putIfAbsent(dish.id, () => []).add(dish);
              }

              final groupedList = groupedDishes.entries.toList();

              return ListView.builder(
                itemCount: groupedList.length,
                itemBuilder: (context, index) {
                  final entry = groupedList[index];
                  final dish = entry.value.first; // Take one as representative
                  // final quantity = entry.value.length;

                  return Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🍕 Dish Image with rounded corners
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: SizedBox(
                                height: 70.h,
                                width: 70.w,
                                child: buildCartImage(dish.imageUrl),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // 📄 Dish Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  Text(
                                    dish.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  // Store Name
                                  Text(
                                    'From ${dish.storeName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),

                                  SizedBox(height: 6.h),

                                  // Price + Button Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Price
                                      Text(
                                        "\$${dish.price.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.greenColor,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),

                                      // 🛒 Add to Cart Button
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ), // small padding inside
                                        height: 28.h, // smaller height
                                        decoration: BoxDecoration(
                                          gradient: AppColors.buttonGradient,
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          onTap: () {
                                            // Navigate to the dish details page
                                            context
                                                .read<PizzaDetailsBloc>()
                                                .add(ResetPizzaDetailsEvent());

                                            // ✅ Then navigate to PizzaDetailsView with dishId
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.pizzaDetails,
                                              arguments:
                                                  dish.id, // pass correct id
                                            );

                                            print(
                                              '👉 Passing Selected Dish ID: ${dish.id}',
                                            );
                                          },
                                          child: Center(
                                            child: Text(
                                              'Order Now',
                                              style: TextStyle(
                                                fontSize: 10.sp, // smaller font
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 2.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: () {
                            context.read<FavoriteBloc>().add(
                              RemoveFromFavoriteEvent(
                                dishId: dish.id, // keep dish id
                                wishlistId:
                                    dish.wishlistId, // pass the wishlist_id
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cancel_rounded,
                              color: Colors.grey,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else if (state is FavoriteError) {
              return Center(child: Text("❌ ${state.message}"));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// 🔹 Cached Network Image with shimmer + fallback
  Widget buildCartImage(String? imageUrl) {
    final fallbackImage = ImageUrls.cheeseLoverPizza; // your fallback image

    return CachedNetworkImage(
      imageUrl: imageUrl ?? fallbackImage,
      fit: BoxFit.cover,
      memCacheHeight: 200, // reduces memory usage
      memCacheWidth: 200, // resizes large image
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) =>
          Image.asset(fallbackImage, fit: BoxFit.cover),
    );
  }
}

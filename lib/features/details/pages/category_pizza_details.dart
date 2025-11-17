import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/bloc/refresh_cubit_helper.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/helpers/bloc_provider_helper.dart';
import 'package:pizza_boys/core/helpers/ui/snackbar_helper.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_bloc.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_event.dart';
import 'package:pizza_boys/features/favorites/bloc/fav_state.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/category/category_state.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class CategoryPizzaDetails extends StatefulWidget {
  final Object? arguments;
  const CategoryPizzaDetails({super.key, this.arguments});

  @override
  State<CategoryPizzaDetails> createState() => _CategoryPizzaDetailsState();
}

class _CategoryPizzaDetailsState extends State<CategoryPizzaDetails> {
  late int categoryId;
  bool _isInitialized = false;
  bool isCDRemoving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args = widget.arguments;

      if (args is Map) {
        if (args['categoryId'] != null) {
          if (args['categoryId'] is int) {
            categoryId = args['categoryId'] as int;
          } else {
            categoryId = int.tryParse(args['categoryId'].toString()) ?? -1;
          }
        } else {
          categoryId = -1;
        }
      } else {
        categoryId = -1;
      }

      // _loadDishes();

      _isInitialized = true;
    }
  }

  // Future<void> _loadDishes() async {
  //   final storeId = await TokenStorage.getChosenStoreId() ?? "-1";
  //   context.read<DishBloc>().add(
  //     GetAllDishesEvent(storeId: storeId, categoryId: categoryId),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[800],
      appBar: AppBar(
        // backgroundColor: Colors.grey[800],
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Pizza",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: " Category",
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoaded && state.categories.isNotEmpty) {
            Future.microtask(() {
              setState(() {
                categoryId = state.categories.first.id;
                print("✅ Updated categoryId after store change: $categoryId");
              });
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MinimalCategoryRow(
              selectedCategoryId: categoryId.toString(),
              onCategorySelected: (id) {
                setState(() => categoryId = int.tryParse(id) ?? -1);
              },
            ),

            Expanded(
              child: BlocBuilder<DishBloc, DishState>(
                builder: (context, state) {
                  if (state is DishLoading) {
                    return const Center(child: LottieLoader());
                  } else if (state is DishLoaded) {
                    final filteredDishes = state.dishes.where((dish) {
                      print(
                        "🔹 Dish: ${dish.name} | dishCategoryId: ${dish.dishCategoryId} | Filter categoryId: $categoryId",
                      );
                      return dish.dishCategoryId == categoryId;
                    }).toList();

                    print(
                      "🔍 Filtered dishes count: ${filteredDishes.length} (categoryId: $categoryId)",
                    );

                    print(
                      "🔍 Filtered dishes count: ${filteredDishes.length} (categoryId: $categoryId)",
                    );

                    if (filteredDishes.isEmpty) {
                      return const Center(
                        child: Text("No items in this category."),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22.0.w,
                            vertical: 6.0.h,
                          ),
                          child: Text(
                            'Recommended for You',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            itemCount: filteredDishes.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final item = filteredDishes[index];
                              print(
                                "🍕 Rendering dish: ${item.name} | Price: ${item.price}",
                              );
                              return _buildDishCard(item);
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is DishError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(DishModel dish) {
    final safeImage = (dish.imageUrl.isNotEmpty)
        ? dish.imageUrl
        : "https://wallpapers.com/images/hd/error-placeholder-image-2e1q6z01rfep95v0.jpg";

    return Stack(
      children: [
        InkWell(
          onTap: () {
            context.read<PizzaDetailsBloc>().add(ResetPizzaDetailsEvent());
            Navigator.pushNamed(
              context,
              AppRoutes.pizzaDetails,
              arguments: dish.id,
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.h, horizontal: 8.w),
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dish Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: CachedNetworkImage(
                    height: 70.w,
                    width: 70.w,
                    imageUrl: safeImage,
                    fit: BoxFit.cover,
                    memCacheWidth: 200,
                    memCacheHeight: 200,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 70.w,
                        height: 70.w,
                        color: Colors.grey[300],
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Dish Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Favorite icon
                      Padding(
                        padding: EdgeInsets.only(right: 22.0.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                dish.name,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                        ),
                      ),

                      // Description
                      if (dish.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dish.description,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black54,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                      ],

                      // Price
                      Text(
                        "\$${dish.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 7.h,
          right: 7.w,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,

           onTap: () async {
  if (isCDRemoving) {
    print("⏳ Remove already in progress… ignoring tap");
    return;
  }

  print("==============================");
  print("⭐ FAVORITE BUTTON PRESSED ⭐");
  print("dishId: ${dish.id}, wishlistId: ${dish.wishlistId}");
  print("==============================");

  final favBloc = context.read<FavoriteBloc>();
  final isGuest = await TokenStorage.isGuest();

  // 🔍 FIND EXISTING FAVORITE
  final favDish = favBloc.getFavoriteDishById(dish.id);
  final isFavorite = favDish != null;

  print("🔥 isFavorite: $isFavorite");

  // ⭐ ADD FLOW
  if (!isFavorite) {
    print("➕ Adding dish ${dish.id} to favorites");
    favBloc.add(AddToFavoriteEvent(dish));
    SnackbarHelper.green(context, "❤️ Added to Favorites!");
    return;
  }

  // ⭐ REMOVE FLOW — guest
  if (isGuest) {
    print("🧑‍🤝‍🧑 Guest removing favorite locally");
    setState(() => isCDRemoving = true);

    favBloc.add(RemoveFromFavoriteEvent(dish: dish));
    // SnackbarHelper.red(context, "Removed from Favorites!");

    // 🔄 ONLY FETCH FAVORITES AGAIN
    favBloc.add(FetchWishlistEvent());

    setState(() => isCDRemoving = false);
    return;
  }

  // ⭐ REMOVE FLOW — logged in (wishlistId available)
  if (favDish?.wishlistId != null) {
    print("🗑 Removing using wishlistId: ${favDish!.wishlistId}");

    setState(() => isCDRemoving = true);

    favBloc.add(
      RemoveFromFavoriteEvent(
        dish: dish,
        wishlistId: favDish.wishlistId,
      ),
    );

    // 🔄 ONLY FETCH FAVORITES AGAIN
    favBloc.add(FetchWishlistEvent());

    setState(() => isCDRemoving = false);
    return;
  }

  // ⭐ wishlistId missing → fetch first
  print("⚠ wishlistId missing! Fetching first…");

  setState(() => isCDRemoving = true);

  // internal fetch+remove logic
  await favBloc.fetchAndRemove(dish);

  print("🗑 Removed after fetch flow");

  // 🔄 ONLY FETCH FAVORITES AGAIN
  favBloc.add(FetchWishlistEvent());

  setState(() => isCDRemoving = false);
},
            child: BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, state) {
                bool isFavorite = false;

                if (state is FavoriteLoaded) {
                  isFavorite = state.favorites.any(
                    (favorite) => favorite.id == dish.id,
                  );
                }

                return isCDRemoving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.redPrimary,
                      );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MinimalCategoryRow extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const MinimalCategoryRow({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 92.h, // responsive height
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
                separatorBuilder: (_, __) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final isActive = item.id.toString() == selectedCategoryId;

                  return GestureDetector(
                    onTap: () => onCategorySelected(item.id.toString()),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 6.h),
                        CircleAvatar(
                          radius: 22.r, // responsive radius
                          backgroundImage: item.categoryImage.isNotEmpty
                              ? NetworkImage(item.categoryImage)
                              : const NetworkImage(
                                  "https://via.placeholder.com/150",
                                ),
                          backgroundColor: Colors.grey[200],
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
                                  ? AppColors.redAccent
                                  : Colors.black87,
                            ),
                            // maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: EdgeInsets.only(top: 3.h),
                            height: 2.h,
                            width: 18.w,
                            color: AppColors.redAccent,
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

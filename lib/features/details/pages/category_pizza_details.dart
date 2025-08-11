import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_event.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_state.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final args = widget.arguments;
      print("🟨 ModalRoute arguments: $args");

      if (args is Map) {
        print("🟦 Args is a Map");

        if (args['categoryId'] != null) {
          print("🟩 categoryId found: ${args['categoryId']}");

          if (args['categoryId'] is int) {
            categoryId = args['categoryId'] as int;
            print("✅ categoryId assigned as int: $categoryId");
          } else {
            print("❌ categoryId type: ${args['categoryId'].runtimeType}");
            categoryId = int.tryParse(args['categoryId'].toString()) ?? -1;
            print("⚠️ categoryId converted to int: $categoryId");
          }
        } else {
          print("❗ categoryId key missing in args");
          categoryId = -1;
        }
      } else {
        print("❌ Arguments are not a Map: ${args.runtimeType}");
        categoryId = -1;
      }

      print("🚀 Dispatching GetAllDishesEvent with categoryId: $categoryId");
      context.read<DishBloc>().add(GetAllDishesEvent(categoryId: categoryId));
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: BlocBuilder<DishBloc, DishState>(
        builder: (context, state) {
          print("📢 BlocBuilder State: ${state.runtimeType}");

          if (state is DishLoading) {
            print("⏳ Loading dishes...");
            return const Center(child: CircularProgressIndicator());
          } else if (state is DishLoaded) {
            print("✅ Dishes loaded: ${state.dishes.length} items");

            final filteredDishes = state.dishes
                .where((dish) => dish.dishCategoryId == categoryId)
                .toList();

            print(
              "🔍 Filtered dishes count: ${filteredDishes.length} (categoryId: $categoryId)",
            );

            if (filteredDishes.isEmpty) {
              print("⚠️ No dishes found for this category.");
              return const Center(child: Text("No items in this category."));
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: filteredDishes.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = filteredDishes[index];
                print("🍕 Rendering dish: ${item.name} | Price: ${item.price}");
                return _buildDishCard(item);
              },
            );
          } else if (state is DishError) {
            print("❌ DishError: ${state.message}");
            return Center(child: Text(state.message));
          } else {
            print("ℹ️ State not recognized: ${state.runtimeType}");
            return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildDishCard(DishModel dish) {
    final safeImage = (dish.imageUrl.isNotEmpty)
        ? dish.imageUrl
        : "https://wallpapers.com/images/hd/error-placeholder-image-2e1q6z01rfep95v0.jpg";

    print("📷 Using image URL: $safeImage");

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🍕 Rounded Pizza Image with caching & shimmer
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: (dish.imageUrl.isEmpty)
                ? Image.asset(
                    ImageUrls.catergoryPizza,
                    height: 70.w,
                    width: 70.w,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    height: 70.w,
                    width: 70.w,
                    imageUrl: 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),

          // 📄 Dish details
          Expanded(
            child: SizedBox(
              height: 90.w, // ✅ Locks height so card doesn't grow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // ✅ Spreads evenly
                children: [
                  // 📝 Dish Name + Fav Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1, // ✅ Prevents overflow
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        color: AppColors.redAccent,
                        size: 20.sp,
                      ),
                    ],
                  ),

                  // 💰 Price + ⭐ Rating
                  Row(
                    children: [
                      Text(
                        "\$${dish.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.star,
                        color: AppColors.ratingYellow,
                        size: 16.sp,
                      ),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Text(
                          dish.rating.toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // 🎟 Coupons + Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "2 Coupons • Upto 30% off",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          minimumSize: Size(80.w, 30.h),
                        ),
                        onPressed: () => print("🛒 Add to Cart: ${dish.name}"),
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/dish/dish_model.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_state.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_event.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_state.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_bloc.dart';
import 'package:pizza_boys/features/home/bloc/integration/dish/dish_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class PizzaDetailsView extends StatefulWidget {
  final int dishId;
  const PizzaDetailsView({super.key, required this.dishId});

  @override
  State<PizzaDetailsView> createState() => _PizzaDetailsViewState();
}

class _PizzaDetailsViewState extends State<PizzaDetailsView> {
  final Map<String, double> addonPrices = const {
    'Extra Cheese': 1.00,
    'Olives Topping': 0.80,
    'Coke (500ml)': 1.50,
    'Garlic Bread': 2.00,
    'French Fries': 2.50,
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<PizzaDetailsBloc>().add(ResetPizzaDetailsEvent());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.scaffoldColor,
          elevation: 0,
          // actions: [
          //   Padding(
          //     padding: EdgeInsets.all(8.0),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.grey.shade200,
          //         shape: BoxShape.circle,
          //       ),
          //       child: IconButton(
          //         icon: Icon(
          //           Icons.favorite_border,
          //           color: AppColors.redPrimary,
          //         ),
          //         onPressed: () {},
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: BlocBuilder<DishBloc, DishState>(
          builder: (context, state) {
            if (state is DishLoading) {
              return Center(child: LottieLoader());
            } else if (state is DishError) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is DishLoaded && state.dishes.isNotEmpty) {
              // ❌ Remove ModalRoute (was causing null)
              final dishId = widget.dishId;
              print(
                "🔹 PizzaDetailsView → Received dishId from constructor: $dishId",
              );

              // ✅ Debug: print all dishes loaded
              print(
                "📦 PizzaDetailsView → Total dishes loaded: ${state.dishes.length}",
              );
              for (var d in state.dishes) {
                print("➡ Dish in list: id=${d.id}, name=${d.name}");
              }

              // ✅ Find the dish matching that id
              final dish = state.dishes.firstWhere(
                (d) => d.id == dishId,
                orElse: () {
                  print(
                    "⚠️ Dish with id=$dishId not found! Falling back to first dish...",
                  );
                  return state.dishes.first;
                },
              );

              print(
                "✅ PizzaDetailsView → Selected dish: id=${dish.id}, name=${dish.name}",
              );

              /// ✅ Safe fallbacks if backend sends nulls
              final imageUrl = (dish.imageUrl?.isNotEmpty ?? false)
                  ? dish.imageUrl
                  : ImageUrls.catergoryPizza; // fallback asset
              final name = dish.name?.isNotEmpty == true
                  ? dish.name
                  : "M and M Pizza";
              final description = dish.description?.isNotEmpty == true
                  ? dish.description
                  : "Delicious handmade pizza with classic toppings & fresh ingredients.";
              final price = dish.price != null ? dish.price!.toDouble() : 12.99;
              final rating = dish.rating != null
                  ? "${dish.rating}/5"
                  : "4.5/5  2,646 Reviews";

              final ingredients = dish.ingredients?.isNotEmpty == true
                  ? dish.ingredients
                  : [];
              final choices = dish.choices?.isNotEmpty == true
                  ? dish.choices
                  : [];

              return BlocBuilder<PizzaDetailsBloc, PizzaDetailsState>(
                builder: (context, detailsState) {
                  final bloc = context.read<PizzaDetailsBloc>();

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ✅ Image Hero
                        Center(
                          child: Hero(
                            tag: 'pizzaHero_${dish.id}',
                            child: Container(
                              width: double.infinity, // 👈 Full width
                              height: 260.h, // 👈 Adjusted height for balance
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black12,
                                //     blurRadius: 20,
                                //     offset: Offset(0, 10),
                                //   ),
                                // ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.r),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit
                                      .cover, // 👈 Fills container properly
                                  memCacheHeight:
                                      700, // 👈 Higher cache size (better quality)
                                  memCacheWidth:
                                      1200, // 👈 Still optimized (not full 20MB)
                                  placeholder: (context, url) =>
                                      const Center(child: LottieLoader()),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                        ImageUrls.catergoryPizza,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        /// ✅ Title + Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              "\$${price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: AppColors.greenColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),

                        /// ✅ Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppColors.ratingYellow,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black54,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (detailsState.quantity > 1) {
                                      bloc.add(
                                        UpdateQuantityEvent(
                                          detailsState.quantity - 1,
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: AppColors.redPrimary,
                                    size: 18.w,
                                  ),
                                ),
                                Text(
                                  detailsState.quantity.toString(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    bloc.add(
                                      UpdateQuantityEvent(
                                        detailsState.quantity + 1,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: AppColors.blackColor,
                                    size: 18.w,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        /// ✅ Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        SizedBox(height: 18.h),

                        /// ✅ Quantity Selector

                        /// ✅ Sizes (always fallback to hardcore Small/Large)
                        Text(
                          'Pick your size!',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: ['Small', 'Large'].map((size) {
                            final isSelected =
                                detailsState.selectedSize == size;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: GestureDetector(
                                  onTap: () {
                                    print("👉 Size tapped: $size");
                                    bloc.add(SelectSizeEvent(size));
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    height: 35.h,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.blackColor
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        color: isSelected
                                            ? AppColors.whiteColor
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        if (detailsState.selectedSize == 'Large') ...[
                          SizedBox(height: 12.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Select your pizza base",
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      FontAwesomeIcons.pizzaSlice,
                                      size: 16.sp,
                                      color: Colors.orange.shade400,
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Wrap(
                                  alignment:
                                      WrapAlignment.center, // ✅ centers chips
                                  spacing: 15.w,
                                  children: [
                                    _buildChipOption(
                                      title: 'Thin Base',
                                      price: 1,
                                      isSelected:
                                          detailsState.selectedLargeOption ==
                                          'Thin Base',
                                      onTap: () {
                                        print(
                                          "👉 Large option tapped: Thin Base | +1",
                                        );
                                        bloc.add(
                                          SelectLargeOptionEvent(
                                            'Thin Base',
                                            1,
                                          ),
                                        );
                                      },
                                    ),
                                    _buildChipOption(
                                      title: 'Gluten Free Base',
                                      price: 3,
                                      isSelected:
                                          detailsState.selectedLargeOption ==
                                          'Gluten Free Base',
                                      onTap: () {
                                        print(
                                          "👉 Large option tapped: Gluten Free Base | +3",
                                        );
                                        bloc.add(
                                          SelectLargeOptionEvent(
                                            'Gluten Free Base',
                                            3,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        SizedBox(height: 18.h),

                        /// ✅ Ingredients (fallback if empty)
                        Text(
                          'Add Extra Ingredients',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (ingredients.isNotEmpty)
                          ...ingredients.map((ing) {
                            return _buildAddonTile(
                              context,
                              ing.name ??
                                  "Extra Cheese", // use property, not map
                              detailsState,
                              bloc,
                            );
                          })
                        else
                          ...['Extra Cheese', 'Olives Topping'].map(
                            (addon) => _buildAddonTile(
                              context,
                              addon,
                              detailsState,
                              bloc,
                            ),
                          ),

                        SizedBox(height: 18.h),

                        /// ✅ Choices (fallback if empty)
                        Text(
                          'Add Side Items',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (choices.isNotEmpty)
                          ...choices.map((choice) {
                            return _buildAddonTile(
                              context,
                              choice.name ?? "Coke (500ml)",
                              detailsState,
                              bloc,
                            );
                          })
                        else
                          ...[
                            'Coke (500ml)',
                            'Garlic Bread',
                            'French Fries',
                          ].map(
                            (addon) => _buildAddonTile(
                              context,
                              addon,
                              detailsState,
                              bloc,
                            ),
                          ),

                        SizedBox(height: 80.h),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),

        /// ✅ Bottom Order Button (with total calculation)
        bottomNavigationBar: BlocBuilder<DishBloc, DishState>(
          builder: (context, dishState) {
            if (dishState is! DishLoaded || dishState.dishes.isEmpty) {
              return const SizedBox.shrink(); // 🔹 nothing until loaded
            }

            final dish = dishState.dishes.firstWhere(
              (d) => d.id == widget.dishId,
              orElse: () => dishState.dishes.first,
            );

            return BlocBuilder<PizzaDetailsBloc, PizzaDetailsState>(
              builder: (context, detailsState) {
                final total = _getTotal(detailsState, dish);

                return BlocConsumer<CartBloc, CartState>(
                  listener: (context, state) {
                    if (state is CartSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Added to cart successfully!"),
                        ),
                      );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.cartView,
                        arguments: {
                          "imageUrl": dish.imageUrl,
                          "name": dish.name,
                          "price": total,
                        },
                      );
                    } else if (state is CartFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Failed: ${state.error}")),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: state is CartLoading
                              ? null
                              : () async {
                                  // 🔎 Debug before sending event
                                  print("🛒 [UI] AddToCart tapped");

                                  final userId = await TokenStorage.getUserId();
                                  final storeId =
                                      await TokenStorage.getChosenStoreId();

                                  if (userId == null || storeId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "⚠️ User or Store not found in session",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  print("👤 userId: $userId");
                                  print("🍕 dishId: ${dish.id}");
                                  print("🏬 storeId: $storeId");
                                  print(
                                    "🔢 quantity: ${detailsState.quantity}",
                                  );
                                  print("💲 price: $total");

                                  final optionsJson = {
                                    "size": detailsState.selectedSize,
                                    "largeOption":
                                        detailsState.selectedLargeOption,
                                    "addons": detailsState.selectedAddons,
                                    "choices": detailsState.selectedChoices,
                                  };

                                  print(
                                    "⚙️ optionsJson: ${jsonEncode(optionsJson)}",
                                  );

                                  context.read<CartBloc>().add(
                                    AddToCartEvent(
                                      userId: int.parse(
                                        userId,
                                      ), // convert back to int
                                      dishId: dish.id,
                                      storeId: int.parse(storeId),
                                      quantity: detailsState.quantity,
                                      price: total,
                                      optionsJson: jsonEncode(optionsJson),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.redPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: state is CartLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Total \$${total.toStringAsFixed(2)} - Order Now!',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _getTotal(PizzaDetailsState state, DishModel dish) {
    double total = dish.price ?? 0;

    print("💲 base price: ${dish.price}");

    // 👇 Size adjustment
    if (state.selectedSize == "Medium") {
      total += 2.0;
    } else if (state.selectedSize == "Large") {
      total += 4.0;
    }

    // 👇 Large option (Thin / Gluten Free)
    total += state.largeOptionExtraPrice;

    // 👇 Use bloc-calculated addon & choice totals
    total += state.addonExtraPrice;
    total += state.choiceExtraPrice ?? 0; // if you added this in state

    // 👇 Multiply by quantity
    double finalTotal = total * state.quantity;

    print("🔢 final total (x${state.quantity}): $finalTotal");

    return finalTotal;
  }

  Widget _buildChipOption({
    required String title,
    required double price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.redPrimary : Colors.white,
          borderRadius: BorderRadius.circular(5.r),
          // border: Border.all(
          //   color: isSelected ? Colors.redAccent : Colors.grey.shade400,
          //   width: 1,
          // ),
        ),
        child: Text(
          '$title (+\$$price)',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.whiteColor : Colors.black87,
          ),
        ),
      ),
    );
  }

  IconData? getAddonIcon(String title) {
    switch (title) {
      case 'Extra Cheese':
        return FontAwesomeIcons.cheese;
      case 'Olives Topping':
        return FontAwesomeIcons.seedling;
      case 'Coke (500ml)':
        return FontAwesomeIcons.bottleWater; // or glassWater
      case 'Garlic Bread':
        return FontAwesomeIcons.breadSlice;
      case 'French Fries':
        return FontAwesomeIcons.burger; // closest if no fries icon
      default:
        return FontAwesomeIcons.utensils;
    }
  }

  Widget _buildAddonTile(
    BuildContext context,
    String title,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc, {
    bool isChoice = false, // set true for side items
  }) {
    final isSelected = isChoice
        ? state.selectedChoices.contains(title)
        : state.selectedAddons[title] ?? false;

    final price = addonPrices[title]?.toStringAsFixed(2) ?? '0.00';
    final iconData = getAddonIcon(title);

    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        if (isChoice) {
          bloc.add(ToggleChoiceEvent(title));
        } else {
          bloc.add(ToggleAddonEvent(title));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              // 👈 This fixes the overflow
              child: Row(
                children: [
                  if (iconData != null) ...[
                    Icon(iconData, size: 18.sp, color: Colors.black),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    // 👈 Constrain text inside row
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize:
                  MainAxisSize.min, // 👈 Prevent unnecessary expansion
              children: [
                Text(
                  '\$$price',
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 22.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blackColor
                        : Colors.transparent,
                    border: Border.all(color: Colors.black45, width: 1.2.w),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

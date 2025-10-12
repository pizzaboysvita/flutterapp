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
import 'package:pizza_boys/data/models/dish/addon_model.dart';
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
  // Selected options
  String? selectedBase;
  List<String> selectedToppings = [];
  Map<String, int> sauceQuantity = {};
  List<String> selectedIngredients = [];

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
          backgroundColor: AppColors.scaffoldColor(context),
          elevation: 0,
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.only(left: 2.0.w),
            child: Image.asset(
              ImageUrls.logo, // replace with your image path
              height: 23.sp, // matches your text height
              fit: BoxFit.contain,
            ),
          ),
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
              for (var d in state.dishes) {}

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

              print(
                "🎯 UI → ComboDishes available for ${dish.name}: ${dish.comboDishes.length}",
              );

              for (var cd in dish.comboDishes) {
                print(
                  "   → ComboDish: id=${cd.id}, name=${cd.name}, price=${cd.price}, image=${cd.imageUrl}",
                );
              }

              /// ✅ Safe fallbacks if backend sends nulls
              final imageUrl = (dish.imageUrl?.isNotEmpty ?? false)
                  ? dish.imageUrl
                  : ImageUrls.catergoryPizza; // fallback asset
              final name = dish.name.isNotEmpty == true ? dish.name : "";
              final description = dish.description.isNotEmpty == true
                  ? dish.description
                  : "";
              final price = dish.price != null ? dish.price!.toDouble() : 12.99;
              // final rating = dish.rating != null
              //     ? "${dish.rating}/5"
              //     : "4.5/5  2,646 Reviews";

              return BlocBuilder<PizzaDetailsBloc, PizzaDetailsState>(
                builder: (context, detailsState) {
                  final bloc = context.read<PizzaDetailsBloc>();
                  // ❗ This is the missing variable
                  final dishSelection = detailsState;

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
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.r),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  memCacheHeight: 700,
                                  memCacheWidth: 1200,
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

                        // Loop through dynamic option sets
                        ...dish.optionSets.map((optionSet) {
                          return _buildDynamicOptionSet(
                            optionSet,
                            dishSelection,
                            bloc,
                          );
                        }).toList(),

                        if (dish.ingredients.isNotEmpty)
                          _buildIngredientsSection(
                            dish.ingredients,
                            dishSelection,
                            bloc,
                          ),

                        if (dish.choices.isNotEmpty)
                          _buildChoicesSection(
                            dish.choices,
                            dishSelection,
                            bloc,
                          ),

                        if (dish.comboDishes.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dish.comboDishes.map((comboDish) {
                              final isSelected =
                                  detailsState.selectedComboDish?.id ==
                                  comboDish.id;
                              final bloc = context.read<PizzaDetailsBloc>();

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: EdgeInsets.symmetric(
                                  vertical: 6.h,
                                  horizontal: 8.w,
                                ),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.grey[100]
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black26
                                        : Colors.grey.shade300,
                                    width: isSelected ? 1.2 : 0.8,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Combo Dish Header
                                    InkWell(
                                      borderRadius: BorderRadius.circular(10.r),
                                      onTap: () {
                                        final isAlreadySelected =
                                            bloc.state.selectedComboDish.id ==
                                            comboDish.id;

                                        if (isAlreadySelected) {
                                          bloc.add(ResetPizzaDetailsEvent());
                                        } else {
                                          bloc.add(
                                            FetchComboDishDetailsEvent(
                                              comboDish.id,
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10.h,
                                          horizontal: 8.w,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                comboDish.name,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                  color: isSelected
                                                      ? Colors.black
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            AnimatedRotation(
                                              turns: isSelected ? 0.5 : 0,
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              child: Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: 22.sp,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    /// Expanded Section (Accordion Body)
                                    AnimatedCrossFade(
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Container(
                                        margin: EdgeInsets.only(top: 8.h),
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ...detailsState
                                                .selectedComboDish
                                                .optionSets
                                                .map(
                                                  (optionSet) =>
                                                      _buildDynamicOptionSet(
                                                        optionSet,
                                                        detailsState,
                                                        bloc,
                                                      ),
                                                ),

                                            /// Ingredients
                                            if (detailsState
                                                .selectedComboDish
                                                .ingredients
                                                .isNotEmpty)
                                              _buildIngredientsSection(
                                                detailsState
                                                    .selectedComboDish
                                                    .ingredients,
                                                detailsState,
                                                bloc,
                                              ),

                                            /// Choices
                                            if (detailsState
                                                .selectedComboDish
                                                .choices
                                                .isNotEmpty)
                                              _buildChoicesSection(
                                                detailsState
                                                    .selectedComboDish
                                                    .choices,
                                                detailsState,
                                                bloc,
                                              ),
                                          ],
                                        ),
                                      ),
                                      crossFadeState: isSelected
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        else
                          const SizedBox.shrink(),

                        SizedBox(height: 10.h),
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
              return const SizedBox.shrink(); // nothing until loaded
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
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("✅ Added to cart successfully!"),
                      //   ),
                      // );
                      print(
                        "✅ CartBloc → Added to cart: dishId=${dish.id}, quantity=${detailsState.quantity}, total=\$$total",
                      );

                      Navigator.pushReplacementNamed(
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
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 📦 Quantity Counter
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (detailsState.quantity > 1) {
                                      context.read<PizzaDetailsBloc>().add(
                                        UpdateQuantityEvent(
                                          detailsState.quantity - 1,
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: AppColors.redPrimary,
                                    size: 20.w,
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
                                    context.read<PizzaDetailsBloc>().add(
                                      UpdateQuantityEvent(
                                        detailsState.quantity + 1,
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: AppColors.blackColor,
                                    size: 20.w,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // 🛒 Order Button with Total
                          Expanded(
                            child: SizedBox(
                              // height: 50.h,
                              child: ElevatedButton(
                                onPressed: state is CartLoading
                                    ? null
                                    : () async {
                                        final userId =
                                            await TokenStorage.getUserId();
                                        final storeId =
                                            await TokenStorage.getChosenStoreId();

                                        if (userId == null || storeId == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "⚠️ User or Store not found in session",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final optionsJson = {
                                          "size": detailsState.selectedSize,
                                          "largeOption":
                                              detailsState.selectedLargeOption,
                                          "addons": detailsState.selectedAddons,
                                          "choices":
                                              detailsState.selectedChoices,
                                        };

                                        context.read<CartBloc>().add(
                                          AddToCartEvent(
                                            type: "insert",
                                            userId: int.parse(userId),
                                            dishId: dish.id,
                                            storeId: int.parse(storeId),
                                            quantity: detailsState.quantity,
                                            price: total,
                                            optionsJson: jsonEncode(
                                              optionsJson,
                                            ),
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
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : Text(
                                        'Total \$${total.toStringAsFixed(2)} (NZD)',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                            ),
                          ),
                        ],
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

  // dynamic option_type(radio,counter,checkbox)
  Widget _buildDynamicOptionSet(
    OptionSet optionSet,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc,
  ) {
    switch (optionSet.optionType.toLowerCase()) {
      case "radio":
        return _buildBaseOptionSet(optionSet, state, bloc);

      case "checkbox":
        return _buildToppingsOptionSet(optionSet, state, bloc);

      case "counter":
        return _buildSaucesOptionSet(optionSet, state, bloc);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBaseOptionSet(
    OptionSet optionSet,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              optionSet.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          /// Base radio options (one selectable)
          ...optionSet.options.map((opt) {
            final isSelected = state.selectedBase == opt.name;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => bloc.add(SelectBaseEvent(opt.name, opt.price)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Base name
                      Expanded(
                        child: Text(
                          opt.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      /// Price
                      Text(
                        '\$${opt.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 12.w),

                      /// Custom radio button (like checkbox style but circular)
                      Container(
                        width: 22.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black45,
                            width: 1.2.w,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12.w,
                                  height: 12.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 8.0.h),
        ],
      ),
    );
  }

  Widget _buildToppingsOptionSet(
    OptionSet optionSet,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),

      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              optionSet.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600, // Semi-bold for section titles
                color: Colors.black87,
              ),
            ),
          ),

          ...optionSet.options.asMap().entries.map((entry) {
            final index = entry.key;
            final opt = entry.value;
            final isSelected = state.selectedToppings[opt.name] ?? false;
            final isMostOrdered = index == 0;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () => bloc.add(
                  ToggleToppingEvent(opt.name, {
                    for (var o in optionSet.options) o.name: o.price,
                  }),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Most Ordered" badge
                      if (isMostOrdered)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 0.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF5E5E), Color(0xFFFF4D4D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Most Ordered',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      if (isMostOrdered) SizedBox(height: 8.h),

                      // Main Row: Icon, name, price, checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Green circular icon
                          // Container(
                          //   width: 16.w,
                          //   height: 16.h,
                          //   child: Icon(
                          //     FontAwesomeIcons.pizzaSlice,
                          //     size: 18.sp,
                          //     color: Colors.black,
                          //   ),
                          // ),
                          // SizedBox(width: 10.w),

                          // Topping name
                          Expanded(
                            child: Text(
                              opt.name,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400, // Regular
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Price with decimals
                          Text(
                            '\$${opt.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight:
                                  FontWeight.w600, // Semi-bold for price
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Custom checkbox
                          Container(
                            width: 22.w,
                            height: 22.h,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              border: Border.all(
                                color: Colors.black45,
                                width: 1.2.w,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSaucesOptionSet(
    OptionSet optionSet,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              optionSet.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          ...optionSet.options.map((opt) {
            final qty = state.sauceQuantities[opt.name] ?? 0;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sauce Name
                  Expanded(
                    child: Text(
                      opt.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Price (always with 2 decimals)
                  Text(
                    "\$${opt.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Counter UI
                  qty == 0
                      ? GestureDetector(
                          onTap: () {
                            bloc.add(
                              UpdateSauceQuantityEvent(opt.name, 1, {
                                for (var o in optionSet.options)
                                  o.name: o.price,
                              }),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              "+ Add",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            children: [
                              // - button
                              GestureDetector(
                                onTap: () {
                                  if (qty > 0) {
                                    bloc.add(
                                      UpdateSauceQuantityEvent(
                                        opt.name,
                                        qty - 1,
                                        {
                                          for (var o in optionSet.options)
                                            o.name: o.price,
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // qty text
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  qty.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              // + button
                              GestureDetector(
                                onTap: () {
                                  bloc.add(
                                    UpdateSauceQuantityEvent(
                                      opt.name,
                                      qty + 1,
                                      {
                                        for (var o in optionSet.options)
                                          o.name: o.price,
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor,
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(
    List<Addon> ingredients,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              "Ingredients",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ...ingredients.map((ing) {
            final isSelected = state.selectedIngredients[ing.name] ?? true;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => bloc.add(ToggleIngredientEvent(ing.name)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Green circular icon
                    // Container(
                    //   width: 16.w,
                    //   height: 16.h,
                    //   child: Icon(
                    //     FontAwesomeIcons.leaf,
                    //     size: 18.sp,
                    //     color: Colors.black,
                    //   ),
                    // ),
                    // SizedBox(width: 10.w),

                    // Topping name
                    Expanded(
                      child: Text(
                        ing.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400, // Regular
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Custom checkbox
                    Container(
                      width: 22.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.transparent,
                        border: Border.all(color: Colors.black45, width: 1.2.w),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChoicesSection(
    List<Addon> choices,
    PizzaDetailsState state,
    PizzaDetailsBloc bloc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "Choices",
        //   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        // ),
        ...choices.map((choice) {
          final isSelected = state.selectedChoices[choice.name] ?? false;
          return InkWell(
            onTap: () => bloc.add(
              ToggleChoiceEvent(choice.name, {
                for (var c in choices) c.name: c.price,
              }),
            ),
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
                    child: Text(
                      "${choice.name} (+\$${choice.price.toStringAsFixed(2)})",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 22.w,
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      border: Border.all(color: Colors.black45, width: 1.2.w),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  double _getTotal(PizzaDetailsState state, DishModel dish) {
    double total = dish.price ?? 0;

    // 👇 Base extra price
    total += state.baseExtraPrice;

    // 👇 Toppings total
    total += state.toppingsExtraPrice;

    // 👇 Sauces total
    total += state.saucesExtraPrice;

    // 👇 Choices total
    total += state.choicesExtraPrice;

    // 👇 Multiply by quantity
    double finalTotal = total * state.quantity;

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
            fontSize: 9.0.sp,
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

  // Widget _buildAddonTile(
  //   BuildContext context,
  //   String title,
  //   PizzaDetailsState state,
  //   PizzaDetailsBloc bloc, {
  //   bool isChoice = false, // set true for side items
  //   double price = 0, // ✅ Add price here
  // }) {
  //   final isSelected = isChoice
  //       ? state.selectedChoices.contains(title)
  //       : state.selectedAddons[title] ?? false;

  //   final priceText = price.toStringAsFixed(2); // use the passed price
  //   final iconData = getAddonIcon(title);

  //   return InkWell(
  //     splashColor: Colors.transparent,
  //     onTap: () {
  //       if (isChoice) {
  //         bloc.add(ToggleChoiceEvent(title));
  //       } else {
  //         bloc.add(ToggleAddonEvent(title));
  //       }
  //     },
  //     child: Container(
  //       margin: EdgeInsets.only(bottom: 8.h),
  //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade100,
  //         borderRadius: BorderRadius.circular(12.r),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Row(
  //               children: [
  //                 if (iconData != null) ...[
  //                   Icon(iconData, size: 18.sp, color: Colors.black),
  //                   SizedBox(width: 8.w),
  //                 ],
  //                 Expanded(
  //                   child: Text(
  //                     title,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 '\$$priceText',
  //                 style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
  //               ),
  //               SizedBox(width: 8.w),
  //               Container(
  //                 width: 22.w,
  //                 height: 22.h,
  //                 decoration: BoxDecoration(
  //                   color: isSelected
  //                       ? AppColors.blackColor
  //                       : Colors.transparent,
  //                   border: Border.all(color: Colors.black45, width: 1.2.w),
  //                   borderRadius: BorderRadius.circular(6.r),
  //                 ),
  //                 child: isSelected
  //                     ? Icon(Icons.check, size: 16.sp, color: Colors.white)
  //                     : null,
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

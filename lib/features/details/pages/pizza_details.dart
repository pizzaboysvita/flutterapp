import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_event.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class PizzaDetailsView extends StatelessWidget {
  const PizzaDetailsView({super.key});

  final Map<String, double> addonPrices = const {
    'Extra Cheese': 1.00,
    'Olives Topping': 0.80,
    'Coke (500ml)': 1.50,
    'Garlic Bread': 2.00,
    'French Fries': 2.50,
  };

  double getTotal(PizzaDetailsState state) {
    double total = 8.99;
    state.selectedAddons.forEach((addon, isSelected) {
      if (isSelected) {
        total += addonPrices[addon] ?? 0;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PizzaDetailsBloc(),
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.scaffoldColor,
          elevation: 0,
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: AppColors.redPrimary,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<PizzaDetailsBloc, PizzaDetailsState>(
          builder: (context, state) {
            final bloc = context.read<PizzaDetailsBloc>();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'pizzaHero',
                      child: Container(
                        width: 240.w,
                        height: 240.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            ImageUrls.catergoryPizza,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'M and M ',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Pizza',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: AppColors.redAccent, // or Colors.red
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$12.99",
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
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.ratingYellow,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '4.5/5   2,646 Reviews',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Delicious handmade pizza with classic toppings & fresh ingredients.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Pick your size!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Sizes row
                  // Main Size Selection
                  Row(
                    children: ['Small', 'Large'].map((size) {
                      final isSelected = state.selectedSize == size;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: GestureDetector(
                            onTap: () {
                              bloc.add(SelectSizeEvent(size));
                              if (size == 'Large') {
                                bloc.add(SelectLargeOptionEvent('', 0));
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 35.h,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.blackColor
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.redAccent.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : [],
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

                  // Sub-options for Large
                  if (state.selectedSize == 'Large') ...[
                    SizedBox(height: 12.h),

                    // Card style container for sub-options
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10.r),
                        // border: Border.all(
                        //   color: Colors.grey.shade300,
                        //   width: 1,
                        // ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Large Options',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Chips
                          Wrap(
                            spacing: 15.w,
                            children: [
                              _buildChipOption(
                                title: 'Thin Base',
                                price: 1,
                                isSelected:
                                    state.selectedLargeOption == 'Thin Base',
                                onTap: () => bloc.add(
                                  SelectLargeOptionEvent('Thin Base', 1),
                                ),
                              ),
                              _buildChipOption(
                                title: 'Gluten Free Base',
                                price: 3,
                                isSelected:
                                    state.selectedLargeOption ==
                                    'Gluten Free Base',
                                onTap: () => bloc.add(
                                  SelectLargeOptionEvent('Gluten Free Base', 3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // SizedBox(height: 18.h),
                  SizedBox(height: 18.h),
                  Text(
                    'Add Extra Ingredients',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...['Extra Cheese', 'Olives Topping'].map(
                    (addon) => _buildAddonTile(context, addon, state, bloc),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Add Side Items',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...['Coke (500ml)', 'Garlic Bread', 'French Fries'].map(
                    (addon) => _buildAddonTile(context, addon, state, bloc),
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<PizzaDetailsBloc, PizzaDetailsState>(
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.cartView);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Total \$${_getTotal(state).toStringAsFixed(2)} - Order Now!',
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
        ),
      ),
    );
  }

  double _getTotal(PizzaDetailsState state) {
    double basePrice = 12.99; // default price

    if (state.selectedSize == 'Large') {
      // If you have a different large price, change it here
      // basePrice = 15.99;
    }

    double total = basePrice + state.largeOptionExtraPrice;

    state.selectedAddons.forEach((addon, selected) {
      if (selected) {
        if (addon == 'Extra Cheese') total += 2.0;
        if (addon == 'Olives Topping') total += 1.5;
        if (addon == 'Coke (500ml)') total += 1.0;
        if (addon == 'Garlic Bread') total += 3.0;
        if (addon == 'French Fries') total += 2.5;
      }
    });

    return total;
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
    PizzaDetailsBloc bloc,
  ) {
    final isSelected = state.selectedAddons[title] ?? false;
    final price = addonPrices[title]?.toStringAsFixed(2) ?? '0.00';
    final iconData = getAddonIcon(title);

    return InkWell(
      splashColor: Colors.transparent,
      onTap: () => bloc.add(ToggleAddonEvent(title)),
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
            Row(
              children: [
                if (iconData != null) ...[
                  Icon(iconData, size: 18.sp, color: Colors.black),
                  SizedBox(width: 8.w),
                ],
                Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
              ],
            ),
            Row(
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

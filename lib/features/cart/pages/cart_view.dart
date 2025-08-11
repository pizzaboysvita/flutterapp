import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/cart/widgets/my_cart/cart_item_tile.dart';
import 'package:pizza_boys/features/cart/widgets/my_cart/meal_addon.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class CartView extends StatefulWidget {
  final ScrollController scrollController;
  final bool showBackButton;
  const CartView({super.key, required this.scrollController,  this.showBackButton = true});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  List<Map<String, dynamic>> cartItems = [
    {
      'name': 'M and M Pizza',
      'price': 8.99,
      'quantity': 1,
      'image': ImageUrls.catergoryPizza,
    },
  ];

  List<Map<String, dynamic>> mealAddons = [
    {
      'name': 'Coke (500ml)',
      'price': 1.50,
      'added': false,
      'image': ImageUrls.coke,
    },
    {
      'name': 'Garlic Bread',
      'price': 2.00,
      'added': false,
      'image': ImageUrls.garlicBread,
    },
    {
      'name': 'French Fries',
      'price': 2.50,
      'added': false,
      'image': ImageUrls.frenchFries,
    },
  ];

  double discount = 0;
  bool useSuperCoins = false;
  String deliveryNote = '';

  double getTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    total -= discount;
    if (useSuperCoins) total -= 2;
    return total > 0 ? total : 0;
  }

  void updateQuantity(int index, bool increase) {
    setState(() {
      if (increase) {
        cartItems[index]['quantity']++;
      } else if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      }
    });
  }

  void applyCoupon(double value) {
    setState(() {
      discount = value;
    });
  }

  void toggleSuperCoins(bool value) {
    setState(() {
      useSuperCoins = value;
    });
  }

  void toggleMealAddon(int index) {
    setState(() {
      mealAddons[index]['added'] = !mealAddons[index]['added'];
      if (mealAddons[index]['added']) {
        cartItems.add({
          'name': mealAddons[index]['name'],
          'price': mealAddons[index]['price'],
          'quantity': 1,
          'image': mealAddons[index]['image'],
        });
      } else {
        cartItems.removeWhere(
          (item) => item['name'] == mealAddons[index]['name'],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
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
                text: " Cart",
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
        child: ListView(
          controller: widget.scrollController,
          children: [
            SizedBox(height: 12.h),
            ...List.generate(
              cartItems.length,
              (index) => CartItemTile(
                item: cartItems[index],
                onIncrement: () => updateQuantity(index, true),
                onDecrement: () => updateQuantity(index, false),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Complete Your Meal',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 140.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mealAddons.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) => MealAddonTile(
                  addon: mealAddons[index],
                  onToggle: () => toggleMealAddon(index),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              onChanged: (value) => deliveryNote = value,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Add Delivery Instructions (Optional)',
                labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12.sp),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '\$${getTotal().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

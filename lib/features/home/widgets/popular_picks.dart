import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class PopularPicks extends StatelessWidget {
  const PopularPicks({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bestSellers = [
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
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Show More',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.redSecondary,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            itemCount: bestSellers.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.75,
            ),

            itemBuilder: (context, index) {
              final item = bestSellers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.pizzaDetails);
                },
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
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12.r),
                                ),
                                child: Image.asset(
                                  item['image'],
                                  width: double.infinity,
                                  height: 100.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "${item['rating']}",
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      "\$${item['price']}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.greenColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "2 Coupons • Upto 30% off",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 32.h,
                                  child: Material(
                                    borderRadius: BorderRadius.circular(10.r),
                                    elevation: 0,
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: AppColors.buttonGradient,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        onTap: () {},
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

                    // Top Choice Tag only for specific item
                    item['name'] == 'Pepperoni Classic'
                        ? Positioned(
                            top: 0.h,
                            left: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBlack,
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
                        : SizedBox(),

                    Positioned(
                      top: 0.h,
                      right: 0.w,
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite_border,
                          size: 16.sp,
                          color: AppColors.redSecondary,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

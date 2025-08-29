import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/core/theme/app_colors.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class CartView extends StatefulWidget {
  final ScrollController scrollController;
  final bool showBackButton;
  final int userId;

  const CartView({
    super.key,
    required this.scrollController,
    required this.userId,
    this.showBackButton = true,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  String deliveryNote = '';

  @override
  void initState() {
    super.initState();
    // ✅ Always fetch latest cart for the logged-in user
    context.read<CartGetBloc>().add(FetchCart(widget.userId));
  }

  double calculateTotal(List cartItems) {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  String extractDishName(Map<String, dynamic> options, {String? fallback}) {
    try {
      if (options.containsKey("selectedOptions")) {
        final selectedOptions = options["selectedOptions"] as List?;
        if (selectedOptions != null && selectedOptions.isNotEmpty) {
          final firstGroup = selectedOptions[0] as List?;
          if (firstGroup != null && firstGroup.isNotEmpty) {
            return firstGroup[0]["name"] ?? fallback ?? "Pizza";
          }
        }
      }
    } catch (_) {}
    return fallback ?? "Pizza";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
        child: BlocBuilder<CartGetBloc, CartGetState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: LottieLoader());
            } else if (state is CartLoaded) {
              final cartItems = state.cartItems;
              if (cartItems.isEmpty) {
                return const Center(child: Text("Your cart is empty"));
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];

                  return Container(
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: SizedBox(
                            height: 50.h,
                            width: 50.w,
                            child: buildCartImage(item.dishImage),
                          ),
                        ),

                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.dishName ?? "Pizza",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Qty: ${item.quantity}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: AppColors.greenColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is CartError) {
              return Center(child: Text("❌ ${state.message}"));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartGetBloc, CartGetState>(
        builder: (context, state) {
          double total = 0;
          if (state is CartLoaded) {
            total = calculateTotal(state.cartItems);
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: const BoxDecoration(
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
                      '\$${total.toStringAsFixed(2)}',
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
                      Navigator.pushNamed(context, AppRoutes.checkOut);
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
          );
        },
      ),
    );
  }

  /// 🔹 Image handler
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

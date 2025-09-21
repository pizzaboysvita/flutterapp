import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_state.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/post/order_post_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/order/post/order_post_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/post/order_post_state.dart';
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
    // Delay event until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartGetBloc>().add(FetchCart(widget.userId));
    });
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
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) async {
        if (state is OrderLoading) {
          print("Order is loading...");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Placing order...")));
        } else if (state is OrderSuccess) {
          print("Order success: ${state.message}");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          // Navigate to order details
          Navigator.pushNamed(
            context,
            AppRoutes.orderDetails,
            arguments: state.order,
          );
          // Optional: Clear cart or navigate
        } else if (state is OrderFailure) {
          print("Order failed: ${state.message}");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ ${state.message}")));
        }
      },
      child: Scaffold(
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
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Dish Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: SizedBox(
                              height: 60.h,
                              width: 60.w,
                              child: buildCartImage(item.dishImage),
                            ),
                          ),

                          SizedBox(width: 12.w),

                          // 🔹 Dish Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dish Name + Remove
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Flexible to avoid overflow
                                    Expanded(
                                      child: Text(
                                        item.dishName ?? "Pizza",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final userId =
                                            await TokenStorage.getUserId();
                                        if (userId == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "⚠️ User not found, please login",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final scaffold = ScaffoldMessenger.of(
                                          context,
                                        );
                                        scaffold.showSnackBar(
                                          const SnackBar(
                                            content: Text("Removing item…"),
                                          ),
                                        );

                                        // Optimistic removal
                                        context.read<CartGetBloc>().add(
                                          RemoveCartItemLocally(item.cartId),
                                        );

                                        try {
                                          context.read<CartBloc>().add(
                                            RemoveFromCartEvent(
                                              cartId: item.cartId,
                                              userId: int.parse(userId),
                                            ),
                                          );

                                          scaffold.hideCurrentSnackBar();
                                          scaffold.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Item removed successfully",
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          // Rollback if failed
                                          context.read<CartGetBloc>().add(
                                            RestoreCartItem(item),
                                          );

                                          scaffold.hideCurrentSnackBar();
                                          scaffold.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Failed to remove item",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(0.w),
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
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                // Qty + Price Row
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Qty: ${item.quantity}",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Flexible(
                                      child: Text(
                                        "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                          color: AppColors.greenColor,
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
                    child: ElevatedButton(
                      onPressed: () async {
                        print("Proceed to Checkout pressed");

                        final cartState = context.read<CartGetBloc>().state;
                        if (cartState is CartLoaded) {
                          final cartItems = cartState.cartItems;
                          print("Cart items: ${cartItems.length}");

                          // Prepare order details
                          final orderDetails = cartItems.map((item) {
                            return OrderDetail(
                              dishId: item.dishId,
                              dishName: item.dishName ?? "Unknown Dish",
                              dishNote: item.dishNote ?? "",
                              quantity: item.quantity,
                              price: item.price,
                              base: item.options["base"] ?? "small",
                              basePrice:
                                  item.options["basePrice"]?.toDouble() ?? 0.0,
                            );
                          }).toList();

                          final toppingDetails = cartItems.map((item) {
                            return ToppingDetail(
                              dishId: item.dishId,
                              name:
                                  item.options["toppingName"] ?? "Extra Cheese",
                              price:
                                  item.options["toppingPrice"]?.toDouble() ??
                                  10.0,
                              quantity: 1,
                            );
                          }).toList();

                          final ingredientDetails = cartItems.map((item) {
                            return IngredientDetail(
                              dishId: item.dishId,
                              name: item.options["ingredientName"] ?? "Tomato",
                              price:
                                  item.options["ingredientPrice"]?.toDouble() ??
                                  2.0,
                              quantity: 1,
                            );
                          }).toList();

                          final userId = await TokenStorage.getUserId();
                          final storeId = await TokenStorage.getChosenStoreId();
                          final formattedDate = DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(DateTime.now());

                          final order = OrderModel(
                            totalPrice: calculateTotal(cartItems),
                            totalQuantity: cartItems.length,
                            storeId: int.parse(storeId!),
                            orderType: "test",
                            pickupDatetime: formattedDate,
                            orderNotes: deliveryNote.isNotEmpty
                                ? deliveryNote
                                : "Customer will pick up",
                            orderStatus: "Order_placed",
                            orderCreatedBy: int.parse(userId!),
                            toppingDetails: toppingDetails,
                            ingredientDetails: ingredientDetails,
                            orderDetails: orderDetails,
                            paymentMethod: "Cash",
                            paymentStatus: "Completed",
                            paymentAmount: calculateTotal(cartItems),
                            unitNumber: "POS-001",
                            gstPrice: 0.1,
                          );

                          print("Dispatching PlaceOrderEvent $order");

                          // Dispatch the order event
                          context.read<OrderBloc>().add(PlaceOrderEvent(order));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 16.w,
                        ),
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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

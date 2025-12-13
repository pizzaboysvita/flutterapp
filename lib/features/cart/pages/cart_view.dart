import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/core/storage/guset_local_storage.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/get/cart_get_state.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/mycart/integration/post/cart_event.dart';

import 'package:pizza_boys/features/details/bloc/pizza_details_bloc.dart';
import 'package:pizza_boys/features/details/bloc/pizza_details_event.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class CartView extends StatefulWidget {
  final bool showBackButton;

  const CartView({super.key, this.showBackButton = true});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  String deliveryNote = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isGuest = await TokenStorage.isGuest();

      if (isGuest) {
        debugPrint("🟨 Fetching cart for GUEST user");
        context.read<CartGetBloc>().add(FetchCart(0)); // guest
      } else {
        final userIdStr = await TokenStorage.getUserId();
        final userId = int.tryParse(userIdStr ?? '0') ?? 0;
        debugPrint("🟩 Fetching cart for LOGGED-IN user: $userId");
        context.read<CartGetBloc>().add(FetchCart(userId));
      }
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
            debugPrint(
              "🧩 [CartGetBloc] Builder triggered — current state: ${state.runtimeType}",
            );

            if (state is CartLoading) {
              debugPrint("⏳ [CartGetBloc] Loading cart items...");
              return const Center(child: LottieLoader());
            }

            if (state is CartLoaded) {
              final cartItems = state.cartItems;
              debugPrint(
                "✅ [CartGetBloc] Cart loaded. Items count: ${cartItems.length}",
              );

              if (cartItems.isEmpty) {
                debugPrint("🛒 [CartGetBloc] Cart is EMPTY!");
                return const Center(child: Text("Your cart is empty"));
              }

              // Log one sample item if available
              if (cartItems.isNotEmpty) {
                debugPrint("📦 First cart item: ${cartItems.first.toString()}");
              }

              return ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // ✅ Restore pizza data from cart item into bloc
                      context.read<PizzaDetailsBloc>().add(
                        RestorePizzaFromCartEvent(item),
                      );

                      // ✅ Just go BACK — NOT push again
                      Navigator.pop(context);

                      print('👉 Cart item tapped → Dish ID: ${item.dishId}');
                    },
                    child: Container(
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
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () async {
                                        final storeId =
                                            await TokenStorage.getChosenStoreId();
                                        final isGuest =
                                            await TokenStorage.isGuest();
                                        final scaffold = ScaffoldMessenger.of(
                                          context,
                                        );

                                        if (isGuest) {
                                          // 🟨 Guest user — handle everything locally
                                          scaffold.showSnackBar(
                                            const SnackBar(
                                              content: Text("Removing item…"),
                                            ),
                                          );

                                          // Optimistic local remove
                                          context.read<CartGetBloc>().add(
                                            RemoveCartItemLocally(item.cartId),
                                          );

                                          // Update local storage (optional if you maintain guest cart locally)

                                          await LocalCartStorage.removeFromCart(
                                            storeId!,
                                            item.dishId,
                                          );

                                          scaffold.hideCurrentSnackBar();
                                          scaffold.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Item removed successfully",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        // 🟩 Logged-in user flow
                                        final userId =
                                            await TokenStorage.getUserId();
                                        if (userId == null) {
                                          scaffold.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "⚠️ User not found, please login",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        scaffold.showSnackBar(
                                          const SnackBar(
                                            content: Text("Removing item…"),
                                          ),
                                        );

                                        // Optimistic local remove
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
                                            const SnackBar(
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
                      final isGuest =
                          await TokenStorage.isGuest(); // 👈 check guest session

                      if (isGuest) {
                        // 👇 redirect guest user to guest login page
                        Navigator.pushNamed(context, AppRoutes.guestLogin);
                        return;
                      }

                      // ✅ Continue existing logic for logged-in users
                      final cartState = context.read<CartGetBloc>().state;
                      if (cartState is CartLoaded) {
                        final cartItems = cartState.cartItems;

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
                            name: item.options["toppingName"] ?? "Extra Cheese",
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
                          orderType: "online",
                          pickupDatetime: formattedDate,
                          deliveryDatetime: formattedDate,
                          deliveryAddress: null,
                          deliveryFees: 0,

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
                          isPosOrder: 0,
                          gstPrice: 0.1,
                          orderDue: null,
                          orderDueDatetime: null,
                          deliveryNotes: null,
                        );

                        print(" ==== ORDER DEBUG START ====");
                        print("userId: $userId | storeId: $storeId");
                        print("Total items: ${cartItems.length}");
                        print("Total price: ${calculateTotal(cartItems)}");
                        print("Order JSON: ${order.toJson()}");
                        print("==== ORDER DEBUG END ====");

                        Navigator.pushNamed(
                          context,
                          AppRoutes.payments,
                          arguments: order,
                        );
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

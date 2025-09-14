import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/image_urls.dart';
import 'package:pizza_boys/core/reusable_widgets/loaders/lottie_loader.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_bloc.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_event.dart';
import 'package:pizza_boys/features/cart/bloc/order/get/order_get_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';
import 'package:shimmer/shimmer.dart';

class OrderHistoryView extends StatefulWidget {
  final bool fromMyOrderButton; // added flag
  const OrderHistoryView({super.key, this.fromMyOrderButton = false});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  late bool fromMyOrderButton;
  bool isInit = false;
  @override
  void initState() {
    super.initState();
    fromMyOrderButton = widget.fromMyOrderButton;

    // ✅ Trigger fetch event when the view is loaded
    Future.microtask(() {
      context.read<OrderGetBloc>().add(LoadOrdersEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is bool) {
        fromMyOrderButton = args;
      }
      // ✅ Trigger fetch event when the view is loaded
      context.read<OrderGetBloc>().add(LoadOrdersEvent());
      isInit = true;
    }
  }

  Future<bool> _onWillPop() async {
    if (widget.fromMyOrderButton) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
      return false; // prevent default pop
    }
    return true; // allow default pop
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Order",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: " History",
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
          automaticallyImplyLeading: false,

          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (widget.fromMyOrderButton) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: BlocBuilder<OrderGetBloc, OrderGetState>(
            builder: (context, state) {
              if (state is OrderLoading) {
                return const Center(child: LottieLoader());
              } else if (state is OrderLoaded) {
                // First, sort orders by date (latest first)

                if (state.orders.isEmpty) {
                  return const Center(child: Text("No orders yet 🕒"));
                }
                final sortedOrders = List.from(state.orders)
                  ..sort(
                    (a, b) => DateTime.parse(
                      b.pickupDatetime,
                    ).compareTo(DateTime.parse(a.pickupDatetime)),
                  );

                return ListView.builder(
                  itemCount: sortedOrders.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: SizedBox(
                                  height: 50.h,
                                  width: 50.w,
                                  child: buildOrderImage(order.deliveryAddress),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order from Store: ${order.storeId}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${order.pickupDatetime.substring(0, 10)} - ${order.orderStatus}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "Total: \$${order.totalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.greenColor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Additional details below
                          // Text(
                          //   'Payment Method: ${order.paymentMethod}',
                          //   style: TextStyle(
                          //     fontSize: 12.sp,
                          //     color: Colors.black87,
                          //     fontFamily: 'Poppins',
                          //   ),
                          // ),
                          // SizedBox(height: 4.h),
                          // Text(
                          //   'Order Notes: ${order.orderNotes.isNotEmpty ? order.orderNotes : "None"}',
                          //   style: TextStyle(
                          //     fontSize: 12.sp,
                          //     color: Colors.black87,
                          //     fontFamily: 'Poppins',
                          //   ),
                          // ),
                          // SizedBox(height: 4.h),
                          // SizedBox(height: 4.h),
                          // Text(
                          //   'Delivery Address: ${order.deliveryAddress ?? "N/A"}',
                          //   style: TextStyle(
                          //     fontSize: 12.sp,
                          //     color: Colors.black54,
                          //     fontFamily: 'Poppins',
                          //   ),
                          // ),
                          // SizedBox(height: 4.h),
                          // Text(
                          //   'Delivery Fees: \$${order.deliveryFees.toStringAsFixed(2)}',
                          //   style: TextStyle(
                          //     fontSize: 12.sp,
                          //     color: Colors.black54,
                          //     fontFamily: 'Poppins',
                          //   ),
                          // ),
                          // SizedBox(height: 4.h),
                          // Text(
                          //   'GST: \$${order.gstPrice.toStringAsFixed(2)}',
                          //   style: TextStyle(
                          //     fontSize: 12.sp,
                          //     color: Colors.black54,
                          //     fontFamily: 'Poppins',
                          //   ),
                          // ),
                          // SizedBox(height: 4.h),
                          // Text(
                          //   'Unit Number: ${order.unitNumber.isNotEmpty ? order.unitNumber : "N/A"}',
                          //   style: TextStyle(
                          //     fontSize: 12.sp,
                          //     color: Colors.black54,
                          //     fontFamily: 'Poppins',
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  },
                );
              } else if (state is OrderError) {
                return Center(child: Text("❌ ${state.message}"));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // // Helper function to get badge color based on status
  // Color getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'order_placed':
  //       return Colors.blue;
  //     case 'confirmed':
  //       return Colors.orange;
  //     case 'completed':
  //       return Colors.green;
  //     case 'cancelled':
  //       return Colors.red;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  // // Badge widget
  // Widget orderStatusBadge(String status) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
  //     decoration: BoxDecoration(
  //       color: getStatusColor(status),
  //       borderRadius: BorderRadius.circular(12.r),
  //     ),
  //     child: Text(
  //       status.replaceAll('_', ' ').toUpperCase(), // prettify
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 10.sp,
  //         fontWeight: FontWeight.bold,
  //         fontFamily: 'Poppins',
  //       ),
  //     ),
  //   );
  // }

  /// 🔹 Cached network image with fallback
  Widget buildOrderImage(String? imageUrl) {
    final fallbackImage = ImageUrls.cheeseLoverPizza;
    return CachedNetworkImage(
      imageUrl: imageUrl ?? fallbackImage,
      fit: BoxFit.cover,
      memCacheHeight: 200,
      memCacheWidth: 200,
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

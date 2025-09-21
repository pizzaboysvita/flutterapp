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
                    print('UnitNumber of Order ${order.unitNumber}');
                    // total price from order_items total frontend total calc
                    // Suppose this is your orderItems list from the API
                    final List<Map<String, dynamic>> orderItems =
                        order.orderItems;

                    // Step 1: Merge duplicates by dish_id
                    final Map<int, Map<String, dynamic>> mergedItems = {};

                    for (var item in orderItems) {
                      final dishId =
                          int.tryParse(item['dish_id'].toString()) ?? -1;
                      final price =
                          double.tryParse(item['price'].toString()) ?? 0.0;
                      final qty =
                          int.tryParse(item['quantity'].toString()) ?? 0;

                      if (mergedItems.containsKey(dishId)) {
                        mergedItems[dishId]!['quantity'] += qty;
                        mergedItems[dishId]!['totalPrice'] += (price * qty);
                      } else {
                        mergedItems[dishId] = {
                          'dish_id': dishId,
                          'dish_name': item['dish_name'] ?? 'Unknown',
                          'quantity': qty,
                          'totalPrice': price * qty,
                        };
                      }
                    }

                    // Step 2: Convert merged items to list if needed
                    final List<Map<String, dynamic>> uniqueItems = mergedItems
                        .values
                        .toList();

                    // Step 3: Calculate the final total price
                    final double finalTotalPrice = uniqueItems.fold<double>(
                      0,
                      (sum, item) => sum + (item['totalPrice'] as double),
                    );
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
                                    Row(
                                      children: [
                                        Text(
                                          "Order ID: ",
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade700,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow
                                              .ellipsis, // ✅ prevent overflow
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "PB", // black
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    "${order.orderMasterId}", // red
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.redAccent,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 4.h),
                                    Text(
                                      order.unitNumber,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    _buildOrderStatus(
                                      order.orderStatus,
                                      order.pickupDatetime.substring(0, 10),
                                    ),

                                    SizedBox(height: 4.h),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // 💰 Total Price (never overflows)
                                        Expanded(
                                          child: Text(
                                            "Total: \$${order.totalPrice.toStringAsFixed(2)}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.greenColor,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 8.w),

                                        // 📦 Total Items (tappable)
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                          onTap: () {
                                            print(
                                              "📦 Order Items for Order ID ${order.orderMasterId}: ${order.orderItems}",
                                            );
                                            _showOrderItemsBottomSheet(
                                              context,
                                              order.orderItems,
                                            );
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Details",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                size: 18.sp,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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

  // 🔹 Map order status to icons & colors (extendable)
  Widget _buildOrderStatus(String status, String pickupDate) {
    IconData icon;
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case "completed":
        icon = Icons.check_circle;
        color = Colors.green;
        label = "Completed";
        break;
      case "ready":
        icon = Icons.restaurant_menu;
        color = Colors.orange;
        label = "Ready";
        break;
      case "order_placed":
        icon = Icons.shopping_bag;
        color = Colors.blue;
        label = "Placed";
        break;
      case "confirmed":
        icon = Icons.verified;
        color = Colors.teal;
        label = "Confirmed";
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
        label = status; // fallback to backend text
    }

    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            "$pickupDate - $label",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Order Items (Indivisual)
  Future<void> _showOrderItemsBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) async {
    // ✅ Step 1: Merge duplicates by dish_id
    final Map<int, Map<String, dynamic>> mergedItems = {};

    for (var item in items) {
      final dishId = int.tryParse(item['dish_id'].toString()) ?? -1;
      final dishName = item['dish_name'] ?? "Unknown";
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final qty = int.tryParse(item['quantity'].toString()) ?? 0;

      if (mergedItems.containsKey(dishId)) {
        // Add to existing → update quantity & totalPrice
        mergedItems[dishId]!['quantity'] += qty;
        mergedItems[dishId]!['totalPrice'] += (price * qty);
      } else {
        // New dish entry
        mergedItems[dishId] = {
          'dish_id': dishId,
          'dish_name': dishName,
          'quantity': qty,
          'totalPrice': price * qty, // store computed total
        };
      }
    }

    final List<Map<String, dynamic>> uniqueItems = mergedItems.values.toList();

    // ✅ Step 2: Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),

                  // Header: Order (black) + Items (red)
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Order ",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: "Poppins",
                          ),
                        ),
                        TextSpan(
                          text: "Items",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.redAccent,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Items List (merged)
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: uniqueItems.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade300, thickness: 0.8),
                      itemBuilder: (context, index) {
                        final item = uniqueItems[index];
                        final dishName = item['dish_name'];
                        final qty = item['quantity'];
                        final totalPrice = item['totalPrice'];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                dishName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Qty: $qty",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "\$${totalPrice.toStringAsFixed(2)}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // ✅ Sticky Footer: Total Summary
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    margin: EdgeInsets.only(top: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Items: ${uniqueItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Total: \$${uniqueItems.fold<double>(0, (sum, item) => sum + (item['totalPrice'] as double)).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: AppColors.greenColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

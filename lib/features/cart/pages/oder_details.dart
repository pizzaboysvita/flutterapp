import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/core/constant/lottie_urls.dart';
import 'package:pizza_boys/core/storage/api_res_storage.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class OrderDetails extends StatefulWidget {
  final OrderModel order;

  const OrderDetails({super.key, required this.order});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late final OrderModel order;
  final storeName = TokenStorage.getChosenLocation();

  @override
  void initState() {
    super.initState();
     order = widget.order;
    _loadUserNameEmail();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor(context),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Payment Success Block
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 80.h,
                      width: 80.w,
                      child: Lottie.asset(
                        LottieUrls.paymentSuccess,
                        repeat: false,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Payment Successful",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: AppColors.greenColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Thank you for your order!",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.blackColor.withOpacity(0.3),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 🔹 Store / Location Info
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store ${order.storeId.toString()}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.sp,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            order.deliveryAddress ?? "Delivery address not set",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.call,
                          size: 14.sp,
                          color: AppColors.blackColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          order.unitNumber,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 🔹 Delivery Info
              _sectionCard(
                title: "Delivery Information",
                child: FutureBuilder<Map<String, String?>>(
                  future: _loadUserNameEmail(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 40,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final userName = snapshot.data!['name'] ?? "-";
                    final userEmail = snapshot.data!['email'] ?? "-";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoTile("Name", userName),
                        _infoTile(
                          "Email",
                          userEmail,
                        ), // if phone also stored, replace with phone
                        _infoTile("Address", order.deliveryAddress ?? "-"),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // 🔹 Order Items
              _sectionCard(
                title: "Order Items",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ➤ Header Row
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40.w,
                            child: Text(
                              "Qty",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Item",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70.w,
                            child: Text(
                              "Price",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey[300]),

                    // ➤ Item rows
                    ...order.orderDetails!.map((item) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                              child: Text(
                                item.quantity.toString(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${item.dishName}", // Replace with actual dish name if available
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 70.w,
                              child: Text(
                                "\$${item.price.toStringAsFixed(2)}",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    Divider(color: Colors.grey[300]),

                    // ➤ Total row
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40.w,
                          ), // Empty space to align with Qty column
                          Expanded(
                            child: Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70.w,
                            child: Text(
                              "\$${order.totalPrice.toStringAsFixed(2)}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: AppColors.greenColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 🔹 Payment Summary
              _sectionCard(
                title: "Payment Summary",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Method
                    _infoTilePaymentSummary(
                      "Payment Method",
                      order.paymentMethod,
                    ),

                    SizedBox(height: 8.h),
                    // Divider(color: Colors.grey[300]),
                    // // Total Quantity
                    // _infoTilePaymentSummary(
                    //   "Total Quantity",
                    //   order.totalQuantity.toString(),
                    // ),

                    // SizedBox(height: 8.h),
                    // Divider(color: Colors.grey[300]),

                    // // Total Amount
                    // _infoTilePaymentSummary(
                    //   "Total Amount",
                    //   "\$${order.totalPrice.toStringAsFixed(2)}",
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomSummary(),
      ),
    );
  }

  Widget _infoTilePaymentSummary(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.orderHistory,
              arguments: true,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.redPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 14.h,
            ), // Adjust vertical padding
          ),
          child: Text(
            'My Orders',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Future<Map<String, String?>> _loadUserNameEmail() async {
    final name = await TokenStorage.getName();
    final email = await TokenStorage.getEmail();
    return {'name': name ?? "-", 'email': email ?? "-"};
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text.rich(
        TextSpan(
          text: 'Order',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Details',
              style: TextStyle(color: AppColors.redAccent),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
      ),
    );
  }
}

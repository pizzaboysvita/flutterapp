import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_boys/core/constant/app_colors.dart';
import 'package:pizza_boys/data/models/order/order_post_model.dart';
import 'package:pizza_boys/features/cart/widgets/payments/coupon_input.dart';
import 'package:pizza_boys/features/cart/widgets/payments/payment_tile.dart';
import 'package:pizza_boys/features/stripe/bloc/stripe_pay_bloc.dart';
import 'package:pizza_boys/features/stripe/bloc/stripe_pay_event.dart';
import 'package:pizza_boys/features/stripe/bloc/stripe_pay_state.dart';
import 'package:pizza_boys/routes/app_routes.dart';

class PaymentPage extends StatefulWidget {
  final OrderModel order;
  PaymentPage({super.key, required this.order});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController couponController = TextEditingController();
  late final OrderModel order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text.rich(
          TextSpan(
            text: 'Choose',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: ' Payment',
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSectionTitle('Payment Options'),
              SizedBox(height: 15.h),
              const PaymentMethodTile(title: 'Card Online', value: 'card'),
              // const PaymentMethodTile(title: 'Bank Transfer', value: 'bank'),
              SizedBox(height: 20.h),
              CouponInput(controller: couponController, onApply: () {}),

              SizedBox(height: 20.h),

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

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.orderDetails,
              arguments: order, // 👈 pass your order model here
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Payment Success")));
          } else if (state is PaymentFailure) {
            // ScaffoldMessenger.of(
            //   context,
            // ).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));

            print("Error: ${state.error}");
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          }

          // Default Pay Now button for card or initial state
          return _buildBottomPayButton(context, order);
        },
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: Text.rich(
        TextSpan(
          text: 'Payment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Method',
              style: TextStyle(color: AppColors.redAccent),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: _buildStepsIndicator(),
      ),
    );
  }

  Widget _buildStepsIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      child: Row(
        children: [
          _stepIcon(Icons.location_on, true),
          Expanded(child: _dottedLine()),
          _stepIcon(Icons.payment, true),
          Expanded(child: _dottedLine()),
          _stepIcon(Icons.check_circle, false),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, bool active) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: active ? AppColors.blackColor : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Icon(
        icon,
        size: 18.sp,
        color: active ? Colors.white : Colors.grey,
      ),
    );
  }

  Widget _dottedLine() {
    return LayoutBuilder(
      builder: (_, box) {
        final count = (box.maxWidth / 16).floor();
        return Padding(
          padding: EdgeInsets.all(12.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(count, (_) {
              return Container(
                width: 5.w,
                height: 2.h,
                color: Colors.grey.shade400,
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBottomPayButton(BuildContext context, OrderModel order) {
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
            final selectedMethod = context
                .read<PaymentBloc>()
                .state
                .selectedMethod;

            if (selectedMethod == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a payment method")),
              );
              return;
            }
            print('item.totalPrice ${order.totalPrice}');

            final amountInCents = (order.totalPrice * 100).toInt();

            context.read<PaymentBloc>().add(
              InitPaymentSheetEvent(
                amount: amountInCents.toDouble(), // still double for clarity
                currency: "nzd",
                paymentMethod: selectedMethod,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.redPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Pay Now',
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

  PreferredSizeWidget _buildAppBarName(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor(context),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text.rich(
        TextSpan(
          text: 'Choose',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: ' Payment',
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

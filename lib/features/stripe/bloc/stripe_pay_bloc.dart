import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pizza_boys/core/helpers/notification_server.dart';
import 'stripe_pay_event.dart';
import 'stripe_pay_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentInitial()) {
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<InitPaymentSheetEvent>(_onInitPaymentSheet);
  }

  final Dio _dio = Dio();

  void _log(String message) => print("⚡ [PaymentBloc] $message");

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<PaymentState> emit,
  ) {
    _log("Selected Payment Method: ${event.method}");
    emit(PaymentInitial(selectedMethod: event.method));
  }

  Future<void> _onInitPaymentSheet(
    InitPaymentSheetEvent event,
    Emitter<PaymentState> emit,
  ) async {
    _log("Initializing Stripe Card Payment...");
    emit(PaymentLoading(selectedMethod: state.selectedMethod));

    try {
      // 1️⃣ Create PaymentIntent
      final paymentIntent = await _createPaymentIntent(
        event.amount,
        event.currency,
      );

      // 2️⃣ Initialize Stripe PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Pizza Boys',
          style: ThemeMode.light,
        ),
      );

      // 3️⃣ Present PaymentSheet
      await Stripe.instance.presentPaymentSheet();
      emit(PaymentSuccess(selectedMethod: state.selectedMethod));
      _log("Payment success!");

      // ✅ Show in-app overlay notification
      showSimpleNotification(
        Text("Order Placed Successfully!"),
        subtitle: Text("Your pizza order has been confirmed 🍕"),
        background: Colors.green,
        duration: Duration(seconds: 3),
      );

      // ✅ Show local notification (Android/iOS)
      await NotificationService.showOrderNotification(
        title: 'Order Placed Successfully!',
        body: 'Your pizza order has been confirmed 🍕',
      );
    } catch (e) {
      _log("Error processing payment: $e");
      emit(
        PaymentFailure(
          error: e.toString(),
          selectedMethod: state.selectedMethod,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    double amount,
    String currency,
  ) async {
    final int amountInCents = amount.toInt();
    _log(
      "Creating PaymentIntent: ${(amountInCents / 100).toStringAsFixed(2)} $currency",
    );

    final response = await _dio.post(
      'https://api.stripe.com/v1/payment_intents',
      data: {
        'amount': amountInCents.toString(),
        'currency': currency,
        'payment_method_types[]': 'card',
      },
      options: Options(
        headers: {
          'Authorization':
              'Bearer ',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    );

    _log("PaymentIntent created: ${response.data}");
    return response.data;
  }
}

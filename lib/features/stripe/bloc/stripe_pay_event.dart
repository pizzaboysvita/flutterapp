abstract class PaymentEvent {}

class InitPaymentSheetEvent extends PaymentEvent {
  final double amount;
  final String currency;
  final String paymentMethod; // 'card' or 'bank'
  final String? orderId; // add this

  InitPaymentSheetEvent({
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.orderId, // include this
  });
}

class SelectPaymentMethodEvent extends PaymentEvent {
  final String method; // 'card' or 'bank'
  SelectPaymentMethodEvent(this.method);
}

class PresentPaymentSheetEvent extends PaymentEvent {}

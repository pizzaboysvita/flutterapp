abstract class PaymentState {
  final String selectedMethod; // 'card' or 'bank'
  const PaymentState({required this.selectedMethod});
}

class PaymentInitial extends PaymentState {
  const PaymentInitial({String selectedMethod = "card"})
      : super(selectedMethod: selectedMethod);
}

class PaymentLoading extends PaymentState {
  const PaymentLoading({required String selectedMethod})
      : super(selectedMethod: selectedMethod);
}

class PaymentSheetReady extends PaymentState {
  final String clientSecret; // Add this!
  const PaymentSheetReady({
    required this.clientSecret,
    required String selectedMethod,
  }) : super(selectedMethod: selectedMethod);
}

class PaymentSuccess extends PaymentState {
  const PaymentSuccess({required String selectedMethod})
      : super(selectedMethod: selectedMethod);
}

class PaymentFailure extends PaymentState {
  final String error;
  const PaymentFailure({
    required this.error,
    required String selectedMethod,
  }) : super(selectedMethod: selectedMethod);
}

class PaymentBankInstruction extends PaymentState {
  final String instructions;
  const PaymentBankInstruction({
    required this.instructions,
    required super.selectedMethod,
    required String clientSecret,
  });
}

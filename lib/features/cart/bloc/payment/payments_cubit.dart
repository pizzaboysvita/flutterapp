import 'package:flutter_bloc/flutter_bloc.dart';


class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentState.initial());

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedMethod: method));
  }

  void toggleSaveCard(bool value) {
    emit(state.copyWith(saveCard: value));
  }

  void applyCoupon(String code) {
    emit(state.copyWith(couponCode: code));
  }
}



class PaymentState {
  final String selectedMethod;
  final bool saveCard;
  final String couponCode;

  PaymentState({
    required this.selectedMethod,
    required this.saveCard,
    required this.couponCode,
  });

  factory PaymentState.initial() => PaymentState(
        selectedMethod: '',
        saveCard: false,
        couponCode: '',
      );

  PaymentState copyWith({
    String? selectedMethod,
    bool? saveCard,
    String? couponCode,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      saveCard: saveCard ?? this.saveCard,
      couponCode: couponCode ?? this.couponCode,
    );
  }
}

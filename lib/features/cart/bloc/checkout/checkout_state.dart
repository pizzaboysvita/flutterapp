part of 'checkout_cubit.dart';

class CheckoutState {
  final bool isHomeDelivery;
  final bool saveAddress;

  CheckoutState({required this.isHomeDelivery, required this.saveAddress});

  CheckoutState copyWith({bool? isHomeDelivery, bool? saveAddress}) {
    return CheckoutState(
      isHomeDelivery: isHomeDelivery ?? this.isHomeDelivery,
      saveAddress: saveAddress ?? this.saveAddress,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit()
    : super(CheckoutState(isHomeDelivery: true, saveAddress: false));

  void toggleDeliveryMethod(bool isHome) {
    emit(state.copyWith(isHomeDelivery: isHome));
  }

  void toggleSaveAddress(bool value) {
    emit(state.copyWith(saveAddress: value));
  }
}

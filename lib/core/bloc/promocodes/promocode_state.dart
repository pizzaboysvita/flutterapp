import 'package:equatable/equatable.dart';

abstract class PromoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PromoInitial extends PromoState {}

class PromoLoading extends PromoState {}

class PromoLoaded extends PromoState {
  final List<Map<String, dynamic>> promos;
   PromoLoaded(this.promos);

  @override
  List<Object?> get props => [promos];
}

class PromoError extends PromoState {
  final String message;
   PromoError(this.message);

  @override
  List<Object?> get props => [message];
}

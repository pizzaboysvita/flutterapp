import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  final Map<String, dynamic> response;

  const CartSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CartFailure extends CartState {
  final String error;

  const CartFailure(this.error);

  @override
  List<Object?> get props => [error];
}

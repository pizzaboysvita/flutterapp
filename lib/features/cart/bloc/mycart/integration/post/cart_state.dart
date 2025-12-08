import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSuccess extends CartState {
  final String action; // "add" or "remove"
  final Map<String, dynamic> response;

  const CartSuccess(this.response, this.action);

  @override
  List<Object?> get props => [response, action];
}


class CartFailure extends CartState {
  final String error;

  const CartFailure(this.error);

  @override
  List<Object?> get props => [error];
}

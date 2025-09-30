import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

abstract class ServerTimeoutState extends Equatable {
  const ServerTimeoutState();

  @override
  List<Object?> get props => [];
}

class ServerTimeoutInitial extends ServerTimeoutState {}

class ServerTimeoutLoading extends ServerTimeoutState {}

class ServerTimeoutSuccess extends ServerTimeoutState {
  final Response response;

  const ServerTimeoutSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ServerTimeoutFailure extends ServerTimeoutState {
  final String message;

  const ServerTimeoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}

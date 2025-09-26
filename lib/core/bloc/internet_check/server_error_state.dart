import 'package:equatable/equatable.dart';

abstract class ServerTimeoutState extends Equatable {
  const ServerTimeoutState();

  @override
  List<Object?> get props => [];
}

class ServerTimeoutInitial extends ServerTimeoutState {}

class ServerTimeoutLoading extends ServerTimeoutState {}

class ServerTimeoutSuccess extends ServerTimeoutState {}

class ServerTimeoutFailure extends ServerTimeoutState {}

import 'package:equatable/equatable.dart';

abstract class ServerTimeoutEvent extends Equatable {
  const ServerTimeoutEvent();

  @override
  List<Object?> get props => [];
}

class RetryRequestEvent extends ServerTimeoutEvent {}

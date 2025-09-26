import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConnectivityChanged extends ConnectivityEvent {
  final bool hasInternet;

  ConnectivityChanged(this.hasInternet);

  @override
  List<Object?> get props => [hasInternet];
}

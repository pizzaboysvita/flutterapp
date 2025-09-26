import 'package:equatable/equatable.dart';

class ConnectivityState extends Equatable {
  final bool hasInternet;

  const ConnectivityState({required this.hasInternet});

  factory ConnectivityState.initial() => const ConnectivityState(hasInternet: true);

  @override
  List<Object?> get props => [hasInternet];
}

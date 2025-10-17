import 'package:equatable/equatable.dart';

abstract class PromoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPromos extends PromoEvent {
  final int storeId;
   FetchPromos(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

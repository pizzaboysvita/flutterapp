import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_event.dart';
import 'package:pizza_boys/core/bloc/promocodes/promocode_state.dart';
import 'package:pizza_boys/data/repositories/promocodes/promocode_repo.dart';


class PromoBloc extends Bloc<PromoEvent, PromoState> {
  final PromoRepository repository;

  PromoBloc(this.repository) : super(PromoInitial()) {
    on<FetchPromos>(_onFetchPromos);
  }

  Future<void> _onFetchPromos(FetchPromos event, Emitter<PromoState> emit) async {
    emit(PromoLoading());
    try {
      final promos = await repository.fetchPromos(event.storeId);
      emit(PromoLoaded(promos));
    } catch (e) {
      emit(PromoError(e.toString()));
    }
  }
}

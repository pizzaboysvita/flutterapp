import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pizza_boys/core/helpers/firebase/remote_config.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final RemoteConfigService _remoteConfigService;
  Timer? _timer;

  MaintenanceBloc(this._remoteConfigService) : super(MaintenanceInitial()) {
    on<CheckMaintenanceEvent>(_onCheckMaintenance);

    // Check every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      add(CheckMaintenanceEvent());
    });
  }

  Future<void> _onCheckMaintenance(
      CheckMaintenanceEvent event, Emitter<MaintenanceState> emit) async {
    await _remoteConfigService.init();

    if (_remoteConfigService.isAppUnderMaintenance) {
      emit(MaintenanceOn(_remoteConfigService.maintenanceMessage));
    } else {
      emit(MaintenanceOff());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

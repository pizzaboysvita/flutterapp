abstract class MaintenanceState {}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceOn extends MaintenanceState {
  final String message;
  MaintenanceOn(this.message);
}

class MaintenanceOff extends MaintenanceState {}

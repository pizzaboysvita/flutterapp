abstract class StoreSelectionEvent {}

class LoadStoresEvent extends StoreSelectionEvent {}

class SelectStoreEvent extends StoreSelectionEvent {
  final String selectedStore;
  SelectStoreEvent(this.selectedStore);
}
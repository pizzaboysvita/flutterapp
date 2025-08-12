abstract class StoreSelectionEvent {}

class LoadStoresEvent extends StoreSelectionEvent {}

class SelectStoreEvent extends StoreSelectionEvent {
  final int storeId;
  SelectStoreEvent(this.storeId);
}

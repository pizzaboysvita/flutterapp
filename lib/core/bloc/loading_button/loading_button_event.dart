
abstract class LoadingBtnEvent {}

class ButtonPressed extends LoadingBtnEvent {
  final Future<void> Function()? onPressedAsync;

  ButtonPressed({this.onPressedAsync});
}

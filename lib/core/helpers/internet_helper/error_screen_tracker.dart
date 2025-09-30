import 'package:flutter/material.dart';
import 'package:pizza_boys/core/helpers/internet_helper/navigation_error.dart';

enum ErrorScreenType { none, network, server }

class ErrorScreenTracker {
  static ErrorScreenType current = ErrorScreenType.none;
  static bool _isShowing = false;
  static Widget? _currentScreen;
  static BuildContext? _context;

  static bool get isShowing => _isShowing;
  

  static bool isShowingType(Type screenType) {
    return _currentScreen?.runtimeType == screenType;
  }

  static bool canShow(ErrorScreenType type) {
    return !_isShowing || current != type;
  }

  static void set(ErrorScreenType type) {
    current = type;
    _isShowing = true;
  }

  static void reset() {
    current = ErrorScreenType.none;
    _isShowing = false;
    _currentScreen = null;
    _context = null;
  }

static void show(Widget screen, {ErrorScreenType? type}) {
  if (_isShowing && type == current) return;

  if (_isShowing && type != null && type != current) {
    hide();
  }

  _isShowing = true;
  _currentScreen = screen;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NavigatorService.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (type != null) current = type;
  });
}

  static void hide() {
  if (!_isShowing) return;

  NavigatorService.navigatorKey.currentState?.pop();
  reset();
}

static void replace(Widget screen, {ErrorScreenType? type}) {
    hide();
    show(screen, type: type);
}

}

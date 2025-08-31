import 'package:flutter/material.dart';

class DeviceHelper {
  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}

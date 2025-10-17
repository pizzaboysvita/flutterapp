import 'package:flutter/widgets.dart';

class BottomRightCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.4);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width * 0.001,
      size.height,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

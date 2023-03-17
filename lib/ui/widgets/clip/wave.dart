import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    Path path = Path();

    path.lineTo(0, h - 100);
    path.quadraticBezierTo(w * 0.25, h - 200, w * 0.5, h - 100);
    path.quadraticBezierTo(w * 0.75, h, w, h - 100);
    path.lineTo(w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

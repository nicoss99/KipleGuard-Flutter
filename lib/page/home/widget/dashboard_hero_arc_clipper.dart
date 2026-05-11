import 'package:flutter/material.dart';

/// Bottom edge dips down in the center (convex arc into the white area below).
class DashboardHeroArcClipper extends CustomClipper<Path> {
  DashboardHeroArcClipper({required this.arcDepth});

  final double arcDepth;

  @override
  Path getClip(Size size) {
    final path = Path();
    final cornerY = size.height - arcDepth * 0.45;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerY);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + arcDepth * 0.9,
      0,
      cornerY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant DashboardHeroArcClipper oldClipper) =>
      oldClipper.arcDepth != arcDepth;
}

import 'package:flutter/material.dart';

/// Dashed rounded-rect outline (Android `circle_dash_line` style for rectangles).
class RegisterDashedBorderPainter extends CustomPainter {
  RegisterDashedBorderPainter({
    required this.color,
    this.radius = 8,
    this.stroke = 1.5,
    this.dash = 6,
    this.gap = 4,
  });

  final Color color;
  final double radius;
  final double stroke;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics(forceClosed: true)) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash > metric.length) ? metric.length : d + dash;
        canvas.drawPath(metric.extractPath(d, end), paint);
        d = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

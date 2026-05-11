import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';

/// Android `activity_qrscan.xml`: dimmed mask, square cutout, corner accents, animated scan line.
class ScanViewfinderOverlay extends StatefulWidget {
  const ScanViewfinderOverlay({super.key});

  @override
  State<ScanViewfinderOverlay> createState() => _ScanViewfinderOverlayState();
}

class _ScanViewfinderOverlayState extends State<ScanViewfinderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line;

  @override
  void initState() {
    super.initState();
    _line = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat();
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final side = (w - 150.w).clamp(120.0, w);
        final left = (w - side) / 2;
        final top = (h - side) / 2;
        const shade = Color(0x60000000);
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _HolePainter(shade: shade, hole: Rect.fromLTWH(left, top, side, side)),
            ),
            Positioned(
              left: left,
              top: top,
              width: side,
              height: side,
              child: ClipRect(
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _line,
                      builder: (context, _) {
                        final travel = (side - 3.h).clamp(4.0, double.infinity);
                        final y = _line.value * travel;
                        return Positioned(
                          left: 0,
                          right: 0,
                          top: y,
                          height: 3.h,
                          child: const ColoredBox(color: AppColor.primary),
                        );
                      },
                    ),
                    _lTopLeft(),
                    _lTopRight(side),
                    _lBottomLeft(side),
                    _lBottomRight(side),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _lTopLeft() {
    return Positioned(
      left: 0,
      top: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50.w, height: 5.h, color: AppColor.primary),
          Container(width: 5.w, height: 45.h, color: AppColor.primary),
        ],
      ),
    );
  }

  Widget _lTopRight(double side) {
    return Positioned(
      right: 0,
      top: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50.w, height: 5.h, color: AppColor.primary),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Container(width: 5.w, height: 45.h, color: AppColor.primary)],
          ),
        ],
      ),
    );
  }

  Widget _lBottomLeft(double side) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5.w, height: 45.h, color: AppColor.primary),
          Container(width: 50.w, height: 5.h, color: AppColor.primary),
        ],
      ),
    );
  }

  Widget _lBottomRight(double side) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Container(width: 5.w, height: 45.h, color: AppColor.primary)],
          ),
          Container(width: 50.w, height: 5.h, color: AppColor.primary),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter({required this.shade, required this.hole});

  final Color shade;
  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cut = Path()..addRect(hole);
    final p = Path.combine(PathOperation.difference, full, cut);
    canvas.drawPath(p, Paint()..color = shade);
  }

  @override
  bool shouldRepaint(covariant _HolePainter oldDelegate) => oldDelegate.hole != hole;
}

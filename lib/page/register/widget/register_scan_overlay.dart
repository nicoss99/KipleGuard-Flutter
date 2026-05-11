import 'package:flutter/material.dart';

import '../../../theme/app_color.dart';

/// Highlight overlay shown over the camera preview on the ID scan page —
/// dark vignette outside an ID-card sized window with corner brackets and an animated scan line.
class RegisterScanOverlay extends StatefulWidget {
  const RegisterScanOverlay({super.key, this.aspectRatio = 1.586});

  /// ISO/IEC 7810 ID-1 (credit card / MyKad) aspect ratio (~85.6×54 mm).
  final double aspectRatio;

  @override
  State<RegisterScanOverlay> createState() => _RegisterScanOverlayState();
}

class _RegisterScanOverlayState extends State<RegisterScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;

          final frameW = w * 0.84;
          var frameH = frameW / widget.aspectRatio;
          if (frameH > h * 0.7) frameH = h * 0.7;
          final frameRect = Rect.fromCenter(
            center: Offset(w / 2, h / 2),
            width: frameW,
            height: frameH,
          );

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size(w, h),
                painter: _ScanFramePainter(
                  frame: frameRect,
                  scanT: _controller.value,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({required this.frame, required this.scanT});

  final Rect frame;
  final double scanT;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRect(frame);
    final mask = Path.combine(PathOperation.difference, outer, hole);
    canvas.drawPath(
      mask,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    final brackets = Paint()
      ..color = AppColor.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cornerLen = (frame.shortestSide * 0.16).clamp(20.0, 48.0);

    void drawCorner(Offset p, Offset hDir, Offset vDir) {
      canvas.drawLine(p, p + hDir * cornerLen, brackets);
      canvas.drawLine(p, p + vDir * cornerLen, brackets);
    }

    drawCorner(frame.topLeft, const Offset(1, 0), const Offset(0, 1));
    drawCorner(frame.topRight, const Offset(-1, 0), const Offset(0, 1));
    drawCorner(frame.bottomLeft, const Offset(1, 0), const Offset(0, -1));
    drawCorner(frame.bottomRight, const Offset(-1, 0), const Offset(0, -1));

    final innerPad = 6.0;
    final lineY = frame.top + innerPad + (frame.height - innerPad * 2) * scanT;
    final lineRect = Rect.fromLTWH(
      frame.left + innerPad,
      lineY - 1,
      frame.width - innerPad * 2,
      2,
    );
    final lineGradient = LinearGradient(
      colors: [
        AppColor.primary.withValues(alpha: 0),
        AppColor.primary.withValues(alpha: 0.95),
        AppColor.primary.withValues(alpha: 0),
      ],
    );
    canvas.drawRect(
      lineRect,
      Paint()..shader = lineGradient.createShader(lineRect),
    );

    final glowRect = Rect.fromLTWH(
      lineRect.left,
      lineRect.top - 8,
      lineRect.width,
      18,
    );
    final glow = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColor.primary.withValues(alpha: 0),
        AppColor.primary.withValues(alpha: 0.18),
        AppColor.primary.withValues(alpha: 0),
      ],
    );
    canvas.drawRect(glowRect, Paint()..shader = glow.createShader(glowRect));
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter old) =>
      old.scanT != scanT || old.frame != frame;
}

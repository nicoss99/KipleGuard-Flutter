import 'package:flutter/material.dart';

import '../theme/app_color.dart';

/// Branded animated loading spinner (primary color, subtle pulse).
class AppProgressIndicator extends StatefulWidget {
  const AppProgressIndicator({
    super.key,
    this.size,
    this.onDark = false,
    this.strokeWidth,
  });

  const AppProgressIndicator.compact({super.key, this.onDark = false})
      : size = 28,
        strokeWidth = 2.5;

  final double? size;
  final bool onDark;
  final double? strokeWidth;

  @override
  State<AppProgressIndicator> createState() => _AppProgressIndicatorState();
}

class _AppProgressIndicatorState extends State<AppProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color = AppColor.primary;
    final track = AppColor.primary.withValues(alpha: widget.onDark ? 0.22 : 0.14);

    final spinner = CircularProgressIndicator(
      color: color,
      backgroundColor: track,
      strokeWidth: widget.strokeWidth ?? 3,
      strokeCap: StrokeCap.round,
    );

    final animated = AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Transform.scale(scale: _pulse.value, child: child),
      child: spinner,
    );

    if (widget.size == null) return animated;
    return SizedBox(width: widget.size, height: widget.size, child: animated);
  }
}

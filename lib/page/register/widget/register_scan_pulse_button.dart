import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';

/// Animated highlight around the IC scan icon — gently pulses to draw the user to scan.
/// Stops pulsing once the field has a value.
class RegisterScanPulseButton extends StatefulWidget {
  const RegisterScanPulseButton({
    super.key,
    required this.onTap,
    this.active = true,
  });

  final VoidCallback onTap;

  /// When `false`, the pulse stops and the highlight fades to a static idle state.
  final bool active;

  @override
  State<RegisterScanPulseButton> createState() => _RegisterScanPulseButtonState();
}

class _RegisterScanPulseButtonState extends State<RegisterScanPulseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RegisterScanPulseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.animateTo(0, duration: const Duration(milliseconds: 220));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48.w,
          height: 48.w,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.active) _ring(t),
                  _coreCircle(t),
                  Icon(Icons.center_focus_weak, color: AppColor.primary, size: 24.sp),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _coreCircle(double t) {
    final base = widget.active
        ? 0.12 + 0.06 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0)
        : 0.10;
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primary.withValues(alpha: base),
      ),
    );
  }

  Widget _ring(double t) {
    final scale = 1.0 + 0.6 * Curves.easeOut.transform(t);
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.55;
    return IgnorePointer(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.primary.withValues(alpha: opacity),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

}

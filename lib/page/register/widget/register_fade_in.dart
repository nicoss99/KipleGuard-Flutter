import 'package:flutter/material.dart';

/// Light staggered entrance for list rows / form sections — copied from `UnitCallFadeInIndex`.
class RegisterFadeIn extends StatelessWidget {
  const RegisterFadeIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ms = (80 + (index * 28).clamp(0, 160)).clamp(80, 240);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';

/// Animated login field container (shared by text inputs and region picker).
class LoginInputBox extends StatelessWidget {
  const LoginInputBox({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: active ? AppColor.loginScreenBlue : AppColor.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColor.white.withValues(alpha: active ? 0.95 : 0.48),
          width: active ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

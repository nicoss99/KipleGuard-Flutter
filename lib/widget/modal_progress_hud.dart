import 'package:flutter/material.dart';

import '../theme/app_color.dart';

/// Full-screen blocking load overlay for page-level work.
class ModalProgressHud extends StatelessWidget {
  const ModalProgressHud({
    super.key,
    required this.inAsyncCall,
    required this.child,
    this.opacity = 0.35,
  });

  final bool inAsyncCall;
  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (inAsyncCall)
          ModalBarrier(
            dismissible: false,
            color: AppColor.textPrimary.withValues(alpha: opacity),
          ),
        if (inAsyncCall) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

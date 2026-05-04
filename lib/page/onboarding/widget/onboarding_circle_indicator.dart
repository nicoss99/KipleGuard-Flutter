import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';

/// Simple stand-in for Android `CirclePageIndicator` (radius ≈ 6dp × density).
class OnboardingCircleIndicator extends StatelessWidget {
  const OnboardingCircleIndicator({
    super.key,
    required this.length,
    required this.index,
  });

  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (i) {
        final selected = i == index;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: selected ? 10.w : 8.w,
            height: selected ? 10.w : 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColor.primary : AppColor.greyBorder,
            ),
          ),
        );
      }),
    );
  }
}

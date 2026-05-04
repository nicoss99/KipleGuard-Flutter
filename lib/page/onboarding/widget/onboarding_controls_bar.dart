import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import 'onboarding_circle_indicator.dart';

class OnboardingControlsBar extends StatelessWidget {
  const OnboardingControlsBar({
    super.key,
    required this.pageIndex,
    required this.pageCount,
    required this.onPrev,
    required this.onNext,
  });

  final int pageIndex;
  final int pageCount;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = pageIndex == pageCount - 1;
    return ColoredBox(
      color: AppColor.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 20.h),
        child: SizedBox(
          height: 60.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: pageIndex > 0
                    ? TextButton(
                        onPressed: onPrev,
                        child: Text(
                          'Prev',
                          style: AppTextStyle.subtitle.copyWith(
                            color: AppColor.textSecondary,
                          ),
                        ),
                      )
                    : SizedBox(width: 64.w),
              ),
              OnboardingCircleIndicator(
                length: pageCount,
                index: pageIndex,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onNext,
                  child: Text(
                    isLast ? 'Done' : 'Next',
                    style: AppTextStyle.subtitle.copyWith(
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

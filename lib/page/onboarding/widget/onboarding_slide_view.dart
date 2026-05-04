import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../onboarding_slide_data.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.data});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.white,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: data.backgroundGradient),
              child: Lottie.asset(
                data.lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Text(
                  data.titleEn,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.title.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  data.titleBm,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subtitle.copyWith(
                    color: AppColor.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 30.h),
                Text(
                  data.bodyEn,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.body.copyWith(color: AppColor.textPrimary),
                ),
                SizedBox(height: 10.h),
                Text(
                  data.bodyBm,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMuted.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

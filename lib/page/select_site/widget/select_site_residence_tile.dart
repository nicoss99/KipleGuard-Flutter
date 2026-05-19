import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../widget/app_progress_indicator.dart';
import '../residence_choice.dart';
import '../select_site_strings.dart';
import '../select_site_text_style.dart';

/// Site row — card with cover, gradient title, optional current badge.
class SelectSiteResidenceTile extends StatelessWidget {
  const SelectSiteResidenceTile({
    super.key,
    required this.choice,
    required this.onTap,
    this.isCurrent = false,
  });

  final ResidenceChoice choice;
  final VoidCallback onTap;
  final bool isCurrent;

  static final _radius = BorderRadius.circular(AppRadius.md);

  @override
  Widget build(BuildContext context) {
    final h = 148.h;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Material(
        elevation: isCurrent ? 3 : 1,
        shadowColor: AppColor.textPrimary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: isCurrent
              ? const BorderSide(color: AppColor.siteSelectedBorder, width: 2.5)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColor.siteListRowGrey,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Cover(choice: choice),
                _TitleGradient(name: choice.name),
                if (isCurrent) const _CurrentBadge(),
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.white,
                    size: 26.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.choice});

  final ResidenceChoice choice;

  @override
  Widget build(BuildContext context) {
    if (!choice.hasCover) {
      return const _CoverNoImage();
    }
    return CachedNetworkImage(
      imageUrl: choice.coverUrl.trim(),
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(
        color: AppColor.siteListRowGrey,
        child: Center(child: AppProgressIndicator.compact()),
      ),
      errorWidget: (_, _, _) => const _CoverNoImage(),
    );
  }
}

/// No cover URL, or preview/url failed to load.
class _CoverNoImage extends StatelessWidget {
  const _CoverNoImage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.primaryDark,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 56.sp,
          color: AppColor.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _TitleGradient extends StatelessWidget {
  const _TitleGradient({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColor.black.withValues(alpha: 0.72),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 28.h, 40.w, 12.h),
          child: Text(
            name,
            style: SelectSiteTextStyle.bannerTitle(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10.h,
      right: 10.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          child: Text(
            SelectSiteStrings.currentBadge,
            style: SelectSiteTextStyle.bannerTitle().copyWith(fontSize: 11.sp),
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../residence_choice.dart';
import '../select_site_text_style.dart';

/// Android `adapter_residence.xml`: 150dp image + title strip + bottom divider.
class SelectSiteResidenceTile extends StatelessWidget {
  const SelectSiteResidenceTile({
    super.key,
    required this.choice,
    required this.onTap,
  });

  final ResidenceChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = 150.h;
    return Material(
      color: AppColor.siteListRowGrey,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: choice.coverUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return SizedBox();
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColor.textPrimary.withValues(alpha: 0.25),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        choice.name,
                        style: SelectSiteTextStyle.bannerTitle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(height: 1, color: AppColor.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

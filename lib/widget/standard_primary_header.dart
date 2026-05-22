import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_bar_title_format.dart';
import '../theme/app_color.dart';
import '../theme/app_text_style.dart';

/// Consistent shell: primary status-bar inset + white bar + centered [AppTextStyle.title].
/// Matches Android / `RegisterStyledHeader` pattern used across the app.
class StandardPrimaryHeader extends StatelessWidget {
  const StandardPrimaryHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.actions = const [],
    this.elevation = 2,
  });

  final String title;
  final VoidCallback onBack;
  final List<Widget> actions;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: AppColor.primary,
          child: SizedBox(height: top, width: double.infinity),
        ),
        Material(
          color: AppColor.white,
          elevation: elevation,
          shadowColor: AppColor.textPrimary.withValues(alpha: 0.08),
          child: SizedBox(
            height: 52.h,
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColor.primary, size: 20.sp),
                ),
                Expanded(
                  child: Text(
                    AppBarTitleFormat.format(title),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actions.isEmpty)
                  SizedBox(width: 48.w)
                else
                  Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Status bar icons on primary (light icons).
SystemUiOverlayStyle standardPrimaryOverlayStyle() => const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColor.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

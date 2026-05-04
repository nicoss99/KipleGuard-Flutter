import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../dashboard_strings.dart';

/// Bottom strip + elevated register control from `activity_dashboard.xml` footer.
class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final barHeight = 72.h;
    final stackHeight = barHeight + 24.h;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColor.lightGreyBar,
              elevation: 0,
              child: SizedBox(
                height: barHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomItem(
                        icon: Icons.call,
                        label: DashboardStrings.call,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          DashboardStrings.register,
                          style: AppTextStyle.body.copyWith(
                            color: AppColor.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _BottomItem(
                        icon: Icons.qr_code_scanner,
                        label: DashboardStrings.scanQr,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Material(
              elevation: 2,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: Ink(
                  width: 52.w,
                  height: 52.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColor.primary, AppColor.primaryDark],
                    ),
                  ),
                  child: Icon(Icons.person_add_alt_1, color: AppColor.white, size: 24.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 24.sp, color: color),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: AppTextStyle.body.copyWith(color: color, fontSize: 11.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

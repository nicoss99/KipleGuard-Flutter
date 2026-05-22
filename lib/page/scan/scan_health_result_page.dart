import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_bar_title_format.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import 'scan_strings.dart';

/// Android `TemperatureDetailsActivity` entry payload (read-only summary).
class ScanHealthResultPage extends StatelessWidget {
  const ScanHealthResultPage({super.key, required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final entries = payload.entries.where((e) => e.value != null).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          elevation: 2,
          backgroundColor: AppColor.white,
          foregroundColor: AppColor.primary,
          title: Text(
            AppBarTitleFormat.format(ScanStrings.scanQrCode),
            style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) Divider(height: 1.h, color: AppColor.greyBorder),
              ListTile(
                title: Text(entries[i].key, style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp)),
                subtitle: Text('${entries[i].value}', style: AppTextStyle.body),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_bar_title_format.dart';
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import 'scan_strings.dart';

/// Android `FormDetailsActivity` shell until full form UI is ported.
class ScanFormStubPage extends StatelessWidget {
  const ScanFormStubPage({super.key, required this.applicationUuid});

  final String applicationUuid;

  @override
  Widget build(BuildContext context) {
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
            AppBarTitleFormat.format(ScanStrings.applicationTitle),
            style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.w),
          child: SelectableText(
            applicationUuid,
            style: AppTextStyle.body,
          ),
        ),
      ),
    );
  }
}

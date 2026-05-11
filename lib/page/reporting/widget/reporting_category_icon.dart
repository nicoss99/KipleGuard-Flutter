import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/app_color.dart';

/// Android `ReportingStep2Activity.addCategory` icon mapping.
Widget reportingCategoryIcon(String name, {required bool selected, double size = 20}) {
  final n = name.toLowerCase();
  String asset = 'assets/android/drawable/ic_register_plus.xml';
  if (n.contains('car')) asset = 'assets/android/drawable/ic_report_car.xml';
  if (n.contains('break')) asset = 'assets/android/drawable/ic_report_break.xml';
  if (n.contains('facility')) asset = 'assets/android/drawable/ic_report_facility.xml';
  final c = selected ? AppColor.white : AppColor.textSecondary;
  return SvgPicture.asset(asset, width: size.w, height: size.h, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));
}

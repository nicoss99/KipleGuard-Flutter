import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';

/// Android `ReportingStep2Activity.addCategory` icon mapping.
IconData reportingCategoryIconData(String name) {
  final n = name.toLowerCase();
  if (n.contains('car')) return Icons.directions_car_outlined;
  if (n.contains('break')) return Icons.report_problem_outlined;
  if (n.contains('facility')) return Icons.apartment_outlined;
  return Icons.add_circle_outline;
}

Widget reportingCategoryIcon(
  String name, {
  required bool selected,
  double size = 20,
  Color? color,
}) {
  return Icon(
    reportingCategoryIconData(name),
    size: size.sp,
    color: color ?? (selected ? AppColor.primary : AppColor.textSecondary),
  );
}

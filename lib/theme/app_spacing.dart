import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing scale — call from [build] after [ScreenUtilInit].
abstract final class AppSpacing {
  static double get xs => 8.w;
  static double get sm => 12.w;
  static double get md => 16.w;
  static double get lg => 24.w;
}

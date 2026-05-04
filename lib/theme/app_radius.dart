import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Corner radii — call from [build] after [ScreenUtilInit].
abstract final class AppRadius {
  static double get sm => 8.r;
  static double get md => 12.r;
}

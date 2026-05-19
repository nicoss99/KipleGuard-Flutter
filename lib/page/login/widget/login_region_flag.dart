import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'login_region_data.dart';

/// Country flag emoji for MY / ID / VN (no background circle).
class LoginRegionFlag extends StatelessWidget {
  const LoginRegionFlag({
    super.key,
    required this.code,
    this.size,
  });

  final String code;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final base = size ?? 40.w;
    final fontSize = base - 2.sp;
    final option = loginRegionByCode(code);
    final emoji = option?.flagEmoji ?? code;

    return Text(
      emoji,
      style: TextStyle(fontSize: fontSize),
      textAlign: TextAlign.center,
    );
  }
}

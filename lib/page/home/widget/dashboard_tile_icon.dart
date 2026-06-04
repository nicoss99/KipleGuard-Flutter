import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Dashboard module tile artwork (PNG).
class DashboardTileIcon extends StatelessWidget {
  const DashboardTileIcon({
    super.key,
    required this.asset,
    this.size,
  });

  final String asset;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final side = size ?? 56.w;
    return SizedBox(
      width: side,
      height: side,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(Icons.image_not_supported_outlined, size: side * 0.5),
      ),
    );
  }
}

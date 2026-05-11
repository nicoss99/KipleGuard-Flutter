import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders Android-exported dashboard vectors from `assets/home_vectors/` (see `AppAssets`).
class DashboardSvgIcon extends StatelessWidget {
  const DashboardSvgIcon({
    super.key,
    required this.asset,
    required this.size,
    this.colorFilter,
  });

  final String asset;
  final double size;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: colorFilter,
    );
  }
}

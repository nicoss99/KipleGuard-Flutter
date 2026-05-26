import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../auth/guard_models.dart';
import '../profile_strings.dart';
import '../profile_text_style.dart';
import 'edit_profile_divider.dart';
import 'edit_profile_section_title.dart';

class EditProfileResidencesSection extends StatelessWidget {
  const EditProfileResidencesSection({super.key, required this.residences});

  final List<GuardResidence> residences;

  @override
  Widget build(BuildContext context) {
    if (residences.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EditProfileSectionTitle(label: ProfileStrings.residences),
        ...residences.expand((r) sync* {
          yield _ResidenceRow(residence: r);
          yield const EditProfileDivider();
        }),
      ],
    );
  }
}

class _ResidenceRow extends StatelessWidget {
  const _ResidenceRow({required this.residence});

  final GuardResidence residence;

  @override
  Widget build(BuildContext context) {
    final location = [
      if (residence.address.isNotEmpty) residence.address,
      if (residence.city.isNotEmpty) residence.city,
      if (residence.state.isNotEmpty) residence.state,
    ].join(', ');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _thumb(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(residence.name, style: ProfileTextStyle.rowValue),
                if (location.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(location, style: ProfileTextStyle.rowValueMuted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb() {
    final url = residence.imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColor.grey,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.apartment_outlined, color: AppColor.textSecondary, size: 24.sp),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        url,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image_outlined, size: 24.sp),
      ),
    );
  }
}

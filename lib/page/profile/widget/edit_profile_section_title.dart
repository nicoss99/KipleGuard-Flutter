import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../profile_text_style.dart';

class EditProfileSectionTitle extends StatelessWidget {
  const EditProfileSectionTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(label, style: ProfileTextStyle.sectionHeader),
    );
  }
}

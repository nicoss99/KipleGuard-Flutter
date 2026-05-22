import 'package:flutter/material.dart';

import '../../../theme/app_color.dart';

class EditProfileDivider extends StatelessWidget {
  const EditProfileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColor.greyBorder);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../../register/register_strings.dart';
import '../../register/widget/register_section_label.dart';
import '../../register/widget/register_underline_field.dart';
import '../visitor_strings.dart';

class VisitorDetailsFieldsColumn extends StatelessWidget {
  const VisitorDetailsFieldsColumn({
    super.key,
    required this.name,
    required this.ic,
    required this.phone,
    required this.car,
    required this.pass,
    required this.parking,
    required this.temp,
    required this.from,
    required this.readOnly,
  });

  final TextEditingController name;
  final TextEditingController ic;
  final TextEditingController phone;
  final TextEditingController car;
  final TextEditingController pass;
  final TextEditingController parking;
  final TextEditingController temp;
  final TextEditingController from;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final ro = readOnly;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RegisterSectionLabel(RegisterStrings.visitorNameField),
          RegisterUnderlineField(
            controller: name,
            hint: RegisterStrings.nameHint,
            keyboard: TextInputType.name,
            readOnly: ro,
          ),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(RegisterStrings.icPassport),
          RegisterUnderlineField(controller: ic, hint: RegisterStrings.icHint, readOnly: ro),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(RegisterStrings.mobileField),
          RegisterUnderlineField(
            controller: phone,
            hint: RegisterStrings.mobileHint,
            keyboard: TextInputType.phone,
            readOnly: ro,
          ),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(RegisterStrings.carPlateField),
          RegisterUnderlineField(controller: car, hint: RegisterStrings.carHint, readOnly: ro),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(RegisterStrings.passIdField),
          RegisterUnderlineField(controller: pass, hint: RegisterStrings.passIdHint, readOnly: ro),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(VisitorStrings.parkingLot),
          RegisterUnderlineField(controller: parking, hint: RegisterStrings.chooseOne, readOnly: ro),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(RegisterStrings.tempField),
          RegisterUnderlineField(
            controller: temp,
            hint: RegisterStrings.tempHint,
            keyboard: TextInputType.number,
            readOnly: ro,
          ),
          SizedBox(height: 12.h),
          const RegisterSectionLabel(VisitorStrings.visitorFrom),
          RegisterUnderlineField(controller: from, hint: RegisterStrings.companyHint, readOnly: ro),
          if (ro) ...[
            SizedBox(height: 12.h),
            Text('Read-only while visitor is checked in.', style: AppTextStyle.bodyMuted),
          ],
        ],
      ),
    );
  }
}

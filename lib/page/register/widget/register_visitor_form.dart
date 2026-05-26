import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../register_strings.dart';
import 'register_scan_pulse_button.dart';
import 'register_section_label.dart';
import 'register_underline_field.dart';

/// Field stack for `RegisterVisitorDetailsPage` (Android `activity_addvisitor.xml`).
class RegisterVisitorForm extends StatelessWidget {
  const RegisterVisitorForm({
    super.key,
    required this.icController,
    required this.nameController,
    required this.carController,
    required this.mobileController,
    required this.emailController,
    required this.tempController,
    required this.companyController,
    required this.officeEnvironment,
    required this.onScanIc,
    required this.onCarInfo,
  });

  final TextEditingController icController;
  final TextEditingController nameController;
  final TextEditingController carController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final TextEditingController tempController;
  final TextEditingController companyController;
  final bool officeEnvironment;
  final VoidCallback onScanIc;
  final VoidCallback onCarInfo;

  static double get _gap => 22.h;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          label: RegisterStrings.icPassport,
          child: ListenableBuilder(
            listenable: icController,
            builder: (context, _) => RegisterUnderlineField(
              controller: icController,
              hint: RegisterStrings.icHint,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                _UpperCaseFormatter(),
              ],
              suffix: RegisterScanPulseButton(
                onTap: onScanIc,
                active: icController.text.trim().isEmpty,
              ),
            ),
          ),
        ),
        SizedBox(height: _gap),
        _section(
          label: RegisterStrings.visitorNameField,
          child: RegisterUnderlineField(
            controller: nameController,
            hint: RegisterStrings.nameHint,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        SizedBox(height: _gap),
        _carSection(),
        SizedBox(height: _gap),
        _section(
          label: RegisterStrings.mobileField,
          child: RegisterUnderlineField(
            controller: mobileController,
            hint: RegisterStrings.mobileHint,
            keyboard: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
            ],
          ),
        ),
        SizedBox(height: _gap),
        _section(
          label: RegisterStrings.emailField,
          child: RegisterUnderlineField(
            controller: emailController,
            hint: RegisterStrings.emailHint,
            keyboard: TextInputType.emailAddress,
          ),
        ),
        if (officeEnvironment) ...[
          SizedBox(height: _gap),
          _section(
            label: RegisterStrings.companyField,
            child: RegisterUnderlineField(
              controller: companyController,
              hint: RegisterStrings.companyHint,
              textCapitalization: TextCapitalization.words,
            ),
          ),
        ],
        SizedBox(height: _gap),
        _section(
          label: RegisterStrings.tempField,
          child: RegisterUnderlineField(
            controller: tempController,
            hint: RegisterStrings.tempHint,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  Widget _section({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RegisterSectionLabel(label),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _carSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RegisterSectionLabel(RegisterStrings.carPlateField),
        SizedBox(height: 4.h),
        Text(
          RegisterStrings.carRecurringHint,
          style: AppTextStyle.bodyMuted.copyWith(fontSize: 12.sp),
        ),
        SizedBox(height: 2.h),
        RegisterUnderlineField(
          controller: carController,
          hint: RegisterStrings.carHint,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 \-]')),
            _UpperCaseFormatter(),
          ],
          suffix: _suffixIcon(Icons.directions_car, onCarInfo),
        ),
      ],
    );
  }

  Widget _suffixIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(icon, color: AppColor.primary, size: 26.sp),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final upper = newValue.text.toUpperCase();
    if (upper == newValue.text) return newValue;
    return newValue.copyWith(
      text: upper,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

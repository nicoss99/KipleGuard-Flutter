import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../register_models.dart';
import '../register_strings.dart';
import '../register_visitor_draft.dart';
import 'register_add_visitor_button.dart';
import 'register_dropdown_card.dart';
import 'register_gradient_button.dart';
import 'register_photo_strip.dart';
import 'register_section_label.dart';
import 'register_underline_field.dart';
import 'register_visit_schedule_block.dart';
import 'register_visitor_summary_card.dart';

/// Mirrors Android `activity_createvisit.xml` — single scrollable column with consistent 20dp gutter.
class RegisterVisitDetailsBody extends StatelessWidget {
  const RegisterVisitDetailsBody({
    super.key,
    required this.apiTypes,
    required this.selectedType,
    required this.onTypeChanged,
    required this.allowDaysError,
    required this.visitStartText,
    required this.visitEndText,
    required this.onPickVisitStart,
    required this.onPickVisitEnd,
    required this.onClearVisitEnd,
    required this.units,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.hosts,
    required this.selectedHost,
    required this.onHostChanged,
    required this.visitor,
    required this.onAddVisitor,
    required this.onClearVisitor,
    required this.visitPhotos,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemovePhoto,
    required this.passController,
    required this.onSubmit,
    required this.canSubmit,
  });

  final List<RegisterVisitorTypeOption> apiTypes;
  final RegisterVisitorTypeOption? selectedType;
  final ValueChanged<RegisterVisitorTypeOption?> onTypeChanged;
  final bool allowDaysError;
  final String visitStartText;
  final String visitEndText;
  final VoidCallback onPickVisitStart;
  final VoidCallback onPickVisitEnd;
  final VoidCallback onClearVisitEnd;
  final List<RegisterUnitOption> units;
  final RegisterUnitOption? selectedUnit;
  final ValueChanged<RegisterUnitOption?> onUnitChanged;
  final List<RegisterHostOption> hosts;
  final RegisterHostOption? selectedHost;
  final ValueChanged<RegisterHostOption?> onHostChanged;
  final RegisterVisitorDraft? visitor;
  final VoidCallback onAddVisitor;
  final VoidCallback onClearVisitor;
  final List<XFile> visitPhotos;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final ValueChanged<int> onRemovePhoto;
  final TextEditingController passController;
  final VoidCallback onSubmit;
  final bool canSubmit;

  static const _gutter = 20.0;

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        _gutter.w,
        16.h,
        _gutter.w,
        16.h + keyboardBottom,
      ),
      children: [
        if (allowDaysError) ...[
          Text(RegisterStrings.typeNotAllowedToday, style: AppTextStyle.body.copyWith(color: AppColor.red)),
          SizedBox(height: 12.h),
        ],
        RegisterSectionLabel(RegisterStrings.typeOfVisit),
        SizedBox(height: 10.h),
        RegisterDropdownCard<RegisterVisitorTypeOption>(
          value: selectedType,
          options: apiTypes,
          optionLabel: (t) => t.name,
          onChanged: onTypeChanged,
          hint: RegisterStrings.visitTypeHint,
          enabled: apiTypes.isNotEmpty,
          searchHint: RegisterStrings.visitTypeHint,
          emptyText: RegisterStrings.visitKindEmpty,
        ),
        SizedBox(height: 24.h),
        RegisterVisitScheduleBlock(
          startText: visitStartText,
          endText: visitEndText,
          onPickStart: onPickVisitStart,
          onPickEnd: onPickVisitEnd,
          onClearEnd: onClearVisitEnd,
        ),
        SizedBox(height: 24.h),
        RegisterSectionLabel(RegisterStrings.unitField),
        SizedBox(height: 10.h),
        RegisterDropdownCard<RegisterUnitOption>(
          value: selectedUnit,
          options: units,
          optionLabel: (u) => '${u.blockName}-${u.unitName}',
          onChanged: onUnitChanged,
          hint: RegisterStrings.chooseOne,
          enabled: units.isNotEmpty,
          searchHint: RegisterStrings.unitSearchHint,
          emptyText: RegisterStrings.unitEmpty,
        ),
        SizedBox(height: 24.h),
        RegisterSectionLabel(RegisterStrings.hostField),
        SizedBox(height: 10.h),
        RegisterDropdownCard<RegisterHostOption>(
          value: selectedHost,
          options: hosts,
          optionLabel: (h) => h.name,
          onChanged: onHostChanged,
          hint: selectedUnit == null ? RegisterStrings.selectUnitFirst : RegisterStrings.chooseOne,
          enabled: selectedUnit != null && hosts.isNotEmpty,
          searchHint: RegisterStrings.hostSearchHint,
          emptyText: RegisterStrings.hostEmpty,
        ),
        SizedBox(height: 24.h),
        RegisterSectionLabel(RegisterStrings.visitorSection),
        SizedBox(height: 10.h),
        if (visitor case final v? when v.name.isNotEmpty)
          RegisterVisitorSummaryCard(visitor: v, onClear: onClearVisitor)
        else
          RegisterAddVisitorButton(onTap: onAddVisitor),
        SizedBox(height: 24.h),
        RegisterSectionLabel(RegisterStrings.photoSection),
        SizedBox(height: 10.h),
        RegisterPhotoStrip(
          photos: visitPhotos,
          onPickCamera: onPickCamera,
          onPickGallery: onPickGallery,
          onRemoveAt: onRemovePhoto,
        ),
        SizedBox(height: 24.h),
        RegisterSectionLabel(RegisterStrings.passIdField),
        SizedBox(height: 4.h),
        RegisterUnderlineField(controller: passController, hint: RegisterStrings.passIdHint),
        SizedBox(height: 24.h),
        Opacity(
          opacity: canSubmit ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: !canSubmit,
            child: RegisterGradientButton(
              label: RegisterStrings.submit,
              onPressed: onSubmit,
              margin: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

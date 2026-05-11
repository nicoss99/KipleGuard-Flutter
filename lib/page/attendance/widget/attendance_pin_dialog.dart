import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../theme/app_color.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_style.dart';
import '../attendance_provider.dart';
import '../attendance_state.dart';
import '../attendance_strings.dart';

/// PIN entry with enter animation, inline error banner, and submit loading.
abstract final class AttendancePinDialog {
  static Future<void> show({
    required BuildContext context,
    required BuildContext pageContext,
    required WidgetRef ref,
    required AttendanceShiftFlow flow,
  }) {
    final labels = MaterialLocalizations.of(context);
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: labels.modalBarrierDismissLabel,
      barrierColor: AppColor.textPrimary.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return _PinDialogBody(pageContext: pageContext, ref: ref, flow: flow);
      },
      transitionBuilder: (ctx, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _PinDialogBody extends StatefulWidget {
  const _PinDialogBody({
    required this.pageContext,
    required this.ref,
    required this.flow,
  });

  final BuildContext pageContext;
  final WidgetRef ref;
  final AttendanceShiftFlow flow;

  @override
  State<_PinDialogBody> createState() => _PinDialogBodyState();
}

class _PinDialogBodyState extends State<_PinDialogBody> {
  late final TextEditingController _ctrl;
  String? _banner;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _ctrl.text.trim();
    if (pin.length != 6) return;
    setState(() {
      _submitting = true;
      _banner = null;
    });
    final err = await widget.ref
        .read(attendanceProvider.notifier)
        .verifyPinAndPrepareShift(pin6: pin, flow: widget.flow);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null) {
      setState(() => _banner = err);
      return;
    }
    Navigator.of(context).pop();
    if (!widget.pageContext.mounted) return;
    final photoErr = await widget.ref
        .read(attendanceProvider.notifier)
        .capturePhotoAndSubmit();
    if (!widget.pageContext.mounted) return;
    final messenger = ScaffoldMessenger.of(widget.pageContext);
    if (photoErr != null) {
      messenger.showSnackBar(SnackBar(content: Text(photoErr)));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.flow == AttendanceShiftFlow.startShift
                ? AttendanceStrings.shiftStarted
                : AttendanceStrings.shiftEnded,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: Center(
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  8.h,
                ),
                child: Text(
                  AttendanceStrings.enterPin,
                  style: AppTextStyle.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (_banner != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _PinErrorBanner(message: _banner!),
                ),
                SizedBox(height: 10.h),
              ],
              if (_submitting) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppColor.primary,
                      backgroundColor: AppColor.grey,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _ctrl,
                  enabled: !_submitting,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subtitle.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: const BorderSide(
                        color: AppColor.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColor.greyBorder.withValues(alpha: 0.35),
              ),
              ColoredBox(
                color: AppColor.surface,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    12.h,
                    AppSpacing.md,
                    12.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColor.textPrimary,
                            side: const BorderSide(color: AppColor.greyBorder),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: Text(
                            AttendanceStrings.cancel,
                            style: AppTextStyle.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          child: _submitting
                              ? SizedBox(
                                  height: 22.h,
                                  width: 22.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColor.white,
                                  ),
                                )
                              : Text(
                                  AttendanceStrings.submit,
                                  style: AppTextStyle.subtitle.copyWith(
                                    color: AppColor.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinErrorBanner extends StatelessWidget {
  const _PinErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColor.red.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColor.red, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyle.body.copyWith(
                  color: AppColor.red,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

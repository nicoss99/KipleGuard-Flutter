import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../page/reporting/reporting_strings.dart';
import '../theme/app_color.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_style.dart';
import 'api_failed_dialog.dart';
import 'app_progress_indicator.dart';
import 'guard_pin_success_dialog.dart';

/// Returned from [GuardPinDialog] on success (with optional payload) or dismissed without success.
class GuardPinOutcome {
  const GuardPinOutcome.success([this.value]) : ok = true, errorMessage = null;
  const GuardPinOutcome.failure([this.errorMessage]) : ok = false, value = null;

  final bool ok;
  final Object? value;
  final String? errorMessage;
}

enum _PinPhase { enter, loading }

/// Shared Android `dialog_guard_pin.xml` behaviour (reporting + attendance).
class GuardPinDialog extends StatefulWidget {
  const GuardPinDialog({
    super.key,
    required this.onVerify,
    this.defaultFailureText = ReportingStrings.pinNotFound,
  });

  final Future<GuardPinOutcome> Function(String pin) onVerify;
  final String defaultFailureText;

  @override
  State<GuardPinDialog> createState() => _GuardPinDialogState();
}

class _GuardPinDialogState extends State<GuardPinDialog> {
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();
  _PinPhase _phase = _PinPhase.enter;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_onPinChanged);
    _pinFocus.addListener(() {
      if (mounted && _phase == _PinPhase.enter) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _phase == _PinPhase.enter) _pinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onPinChanged() {
    if (!mounted || _phase != _PinPhase.enter) return;
    setState(() {});
    if (_pinController.text.length == 6) _submit();
  }

  void _resetPinEntry() {
    _pinController.clear();
    _pinFocus.requestFocus();
  }

  Future<void> _submit() async {
    final pin = _pinController.text;
    if (pin.length != 6 || _busy) return;
    _busy = true;
    _pinFocus.unfocus();
    setState(() => _phase = _PinPhase.loading);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final outcome = await widget.onVerify(pin);
    if (!mounted) return;
    if (outcome.ok) {
      await showGuardPinSuccessDialog(context);
      if (mounted) Navigator.of(context).pop(outcome);
    } else {
      _busy = false;
      final msg = outcome.errorMessage?.trim();
      final text = (msg != null && msg.isNotEmpty) ? msg : widget.defaultFailureText;
      if (!mounted) return;
      await showApiFailedDialog(context, message: text);
      if (!mounted) return;
      setState(() {
        _phase = _PinPhase.enter;
        _resetPinEntry();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: switch (_phase) {
        _PinPhase.enter => _buildEnter(),
        _PinPhase.loading => const _PinCheckingAnimated(),
      },
    );
  }

  Widget _buildEnter() {
    final pin = _pinController.text;
    final focusIndex = pin.length.clamp(0, 5);
    final hasFocus = _pinFocus.hasFocus;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ReportingStrings.enterMemberPin,
            style: AppTextStyle.title,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: _pinFocus.requestFocus,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 48.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: List.generate(6, (i) {
                    final digit = i < pin.length ? pin[i] : '';
                    final active = hasFocus && i == focusIndex;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          height: 48.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: active ? AppColor.primary : AppColor.greyBorder,
                              width: active ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            digit,
                            style: AppTextStyle.title.copyWith(fontSize: 22.sp),
                          ),
                        ),
                      ),
                    );
                    }),
                  ),
                  Positioned.fill(
                    child: TextField(
                      controller: _pinController,
                      focusNode: _pinFocus,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      enableInteractiveSelection: false,
                      showCursor: false,
                      maxLength: 6,
                      style: AppTextStyle.title.copyWith(
                        fontSize: 22.sp,
                        color: Colors.transparent,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted: (_) {
                        if (_pinController.text.length == 6) _submit();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 50.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              onPressed: pin.length == 6 ? _submit : null,
              child: Text(
                ReportingStrings.submit,
                style: AppTextStyle.body.copyWith(color: AppColor.white),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              ReportingStrings.cancel,
              style: AppTextStyle.body.copyWith(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

}

/// Breathing lock + spinner while PIN is verified (no bitmap / Lottie).
class _PinCheckingAnimated extends StatefulWidget {
  const _PinCheckingAnimated();

  @override
  State<_PinCheckingAnimated> createState() => _PinCheckingAnimatedState();
}

class _PinCheckingAnimatedState extends State<_PinCheckingAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _opacity.value,
                  child: Icon(Icons.lock_outline, size: 40.sp, color: AppColor.textSecondary),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: 30.w,
            height: 30.w,
            child: const AppProgressIndicator.compact(),
          ),
          SizedBox(height: 16.h),
          Text(
            ReportingStrings.checkingPin,
            textAlign: TextAlign.center,
            style: AppTextStyle.title,
          ),
        ],
      ),
    );
  }
}

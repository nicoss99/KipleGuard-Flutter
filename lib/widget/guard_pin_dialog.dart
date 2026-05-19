import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../page/reporting/reporting_strings.dart';
import '../theme/app_color.dart';
import '../theme/app_radius.dart';
import 'app_progress_indicator.dart';
import '../theme/app_text_style.dart';

/// Returned from [GuardPinDialog] on success (with optional payload) or dismissed without success.
class GuardPinOutcome {
  const GuardPinOutcome.success([this.value]) : ok = true, errorMessage = null;
  const GuardPinOutcome.failure([this.errorMessage]) : ok = false, value = null;

  final bool ok;
  final Object? value;
  final String? errorMessage;
}

enum _PinPhase { enter, loading, success, error }

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
  final _c = List.generate(6, (_) => TextEditingController());
  final _f = List.generate(6, (_) => FocusNode());
  _PinPhase _phase = _PinPhase.enter;
  String _failureText = ReportingStrings.pinNotFound;

  @override
  void dispose() {
    for (final x in _c) {
      x.dispose();
    }
    for (final x in _f) {
      x.dispose();
    }
    super.dispose();
  }

  String _code() => _c.map((e) => e.text).join();
  var _busy = false;

  Future<void> _submit() async {
    final pin = _code();
    if (pin.length != 6 || _busy) return;
    _busy = true;
    setState(() => _phase = _PinPhase.loading);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final outcome = await widget.onVerify(pin);
    if (!mounted) return;
    if (outcome.ok) {
      setState(() => _phase = _PinPhase.success);
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop(outcome);
    } else {
      _busy = false;
      final msg = outcome.errorMessage?.trim();
      _failureText = (msg != null && msg.isNotEmpty) ? msg : widget.defaultFailureText;
      setState(() => _phase = _PinPhase.error);
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
        _PinPhase.success => _buildSuccess(),
        _PinPhase.error => _buildError(),
      },
    );
  }

  Widget _buildEnter() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ReportingStrings.enterMemberPin, style: AppTextStyle.title, textAlign: TextAlign.center),
          SizedBox(height: 20.h),
          Row(
            children: List.generate(6, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: TextField(
                    controller: _c[i],
                    focusNode: _f[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: AppTextStyle.title.copyWith(fontSize: 22.sp),
                    decoration: const InputDecoration(counterText: ''),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (t) {
                      if (t.length == 1 && i < 5) _f[i + 1].requestFocus();
                      if (t.isEmpty && i > 0) _f[i - 1].requestFocus();
                      if (_code().length == 6) _submit();
                    },
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 50.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              onPressed: _code().length == 6 ? _submit : null,
              child: Text(ReportingStrings.submit, style: AppTextStyle.body.copyWith(color: AppColor.white)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(ReportingStrings.cancel, style: AppTextStyle.body.copyWith(color: AppColor.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 56.sp, color: AppColor.primary),
          SizedBox(height: 16.h),
          Text(
            ReportingStrings.success,
            style: AppTextStyle.title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.h),
          Icon(Icons.error_outline, size: 50.sp, color: AppColor.red),
          SizedBox(height: 10.h),
          Text(_failureText, textAlign: TextAlign.center, style: AppTextStyle.title),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColor.primary),
              onPressed: () => setState(() {
                _busy = false;
                _phase = _PinPhase.enter;
                for (final x in _c) {
                  x.clear();
                }
                _f[0].requestFocus();
              }),
              child: Text(ReportingStrings.tryAgain, style: AppTextStyle.body.copyWith(color: AppColor.white)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(ReportingStrings.cancel, style: AppTextStyle.body.copyWith(color: AppColor.primary)),
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
          Text(ReportingStrings.checkingPin, textAlign: TextAlign.center, style: AppTextStyle.title),
        ],
      ),
    );
  }
}


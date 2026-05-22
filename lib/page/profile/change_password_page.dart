import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../theme/app_color.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import '../register/widget/register_gradient_button.dart';
import 'change_password_provider.dart';
import 'change_password_validator.dart';
import 'profile_strings.dart';
import 'widget/profile_login_password_field.dart';

/// Android `ChangePasswordActivity` — white background, login label typography.
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  var _obscureCurrent = true;
  var _obscureNew = true;
  var _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    for (final c in [_current, _new, _confirm]) {
      c.addListener(_onFieldsChanged);
    }
  }

  void _onFieldsChanged() {
    if (mounted) setState(() {});
    ref.read(changePasswordProvider.notifier).clearValidation();
  }

  @override
  void dispose() {
    for (final c in [_current, _new, _confirm]) {
      c.removeListener(_onFieldsChanged);
      c.dispose();
    }
    super.dispose();
  }

  bool get _canSave => ChangePasswordValidation.canSubmit(
        current: _current.text,
        newPass: _new.text,
        confirm: _confirm.text,
      );

  Future<void> _save() async {
    final ok = await ref.read(changePasswordProvider.notifier).submit(
          current: _current.text,
          newPass: _new.text,
          confirm: _confirm.text,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ProfileStrings.passwordUpdated)),
      );
      context.pop();
      return;
    }
    final err = ref.read(changePasswordProvider).apiError;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(changePasswordProvider);
    final v = s.validation;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: s.loading,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            children: [
              StandardPrimaryHeader(
                title: ProfileStrings.changePassword,
                onBack: () => context.pop(),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileLoginPasswordField(
                        label: ProfileStrings.currentPassword,
                        hint: ProfileStrings.currentPasswordHint,
                        controller: _current,
                        obscure: _obscureCurrent,
                        onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        errorText: v.currentError ? v.currentMessage : null,
                      ),
                      SizedBox(height: 12.h),
                      ProfileLoginPasswordField(
                        label: ProfileStrings.newPassword,
                        hint: ProfileStrings.newPasswordHint,
                        controller: _new,
                        obscure: _obscureNew,
                        onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                        errorText: v.newError ? v.newMessage : null,
                      ),
                      SizedBox(height: 12.h),
                      ProfileLoginPasswordField(
                        label: ProfileStrings.confirmPassword,
                        hint: ProfileStrings.confirmPasswordHint,
                        controller: _confirm,
                        obscure: _obscureConfirm,
                        onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        errorText: v.confirmError ? v.confirmMessage : null,
                      ),
                      SizedBox(height: 24.h),
                      Opacity(
                        opacity: _canSave ? 1.0 : 0.4,
                        child: IgnorePointer(
                          ignoring: !_canSave,
                          child: RegisterGradientButton(
                            label: ProfileStrings.save,
                            onPressed: _save,
                            margin: EdgeInsets.zero,
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

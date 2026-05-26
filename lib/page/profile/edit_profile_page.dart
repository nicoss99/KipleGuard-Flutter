import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import 'widget/sign_out_dialog.dart';
import '../../widget/standard_primary_header.dart';
import 'profile_provider.dart';
import 'profile_text_style.dart';
import 'profile_state.dart';
import '../register/widget/register_gradient_button.dart';
import 'profile_strings.dart';
import 'widget/edit_profile_divider.dart';
import 'widget/edit_profile_header.dart';
import 'widget/edit_profile_menu_row.dart';
import 'widget/edit_profile_residences_section.dart';
import 'widget/edit_profile_section_title.dart';

/// Android `EditProfileActivity` — local prefs + PUT profile / sign-out APIs.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(profileProvider.notifier).load();
      final s = ref.read(profileProvider);
      _nameCtrl.text = s.savedName;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final ok = await ref.read(profileProvider.notifier).saveName(_nameCtrl.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ProfileStrings.profileUpdated)),
      );
      context.pop(true);
    } else {
      final err = ref.read(profileProvider).error;
      if (err != null) await showApiFailedDialog(context, message: err);
    }
  }

  void _confirmSignOut() {
    showSignOutDialog(
      context,
      onConfirm: () {
        if (!mounted) return;
        _signOut();
      },
    );
  }

  Future<void> _signOut() async {
    final ok = await ref.read(profileProvider.notifier).signOut();
    if (!mounted) return;
    if (ok) {
      while (context.canPop()) {
        context.pop();
      }
      context.go(AppRoute.login.path);
      return;
    }
    await showApiFailedDialog(context, title: 'Sign out failed');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(profileProvider);
    final versionAsync = ref.watch(appVersionLabelProvider);
    ref.listen(profileProvider, (prev, next) {
      final err = next.error;
      if (err == null || err == prev?.error || next.loading || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showApiFailedDialog(context, message: err);
        ref.read(profileProvider.notifier).clearError();
      });
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: s.loading,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardPrimaryHeader(
                title: ProfileStrings.editProfile,
                onBack: () => context.pop(false),
                actions: s.showSave
                    ? [
                        TextButton(
                          onPressed: _saveName,
                          child: Text(
                            ProfileStrings.save,
                            style: ProfileTextStyle.headerAction,
                          ),
                        ),
                      ]
                    : const [],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EditProfileHeader(initials: s.initials),
                      const EditProfileSectionTitle(label: ProfileStrings.account),
                      _nameRow(s),
                      const EditProfileDivider(),
                      EditProfileMenuRow(
                        label: ProfileStrings.changePassword,
                        onTap: () => context.push(AppRoute.changePassword.path),
                      ),
                      const EditProfileDivider(),
                      _readOnlyRow(ProfileStrings.email, s.email),
                      const EditProfileDivider(),
                      _readOnlyRow(ProfileStrings.mobileNumber, s.phone),
                      EditProfileResidencesSection(residences: s.residences),
                      const EditProfileSectionTitle(label: ProfileStrings.helpSupport),
                      EditProfileMenuRow(
                        label: ProfileStrings.whatsNew,
                        onTap: () =>
                            context.push('${AppRoute.onboardingIntro.path}?from=profile'),
                      ),
                      const EditProfileDivider(),
                      EditProfileMenuRow(
                        label: ProfileStrings.offlineData,
                        onTap: () => context.push(AppRoute.profileOffline.path),
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: RegisterGradientButton(
                          label: ProfileStrings.signOut,
                          onPressed: _confirmSignOut,
                          margin: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      versionAsync.when(
                        data: (label) => label.isEmpty
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  8.h,
                                  16.w,
                                  16.h + MediaQuery.paddingOf(context).bottom,
                                ),
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: ProfileTextStyle.version,
                                ),
                              ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
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

  Widget _nameRow(ProfileState s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ProfileStrings.name, style: ProfileTextStyle.rowLabel),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              textAlign: TextAlign.end,
              style: ProfileTextStyle.rowValue,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: ref.read(profileProvider.notifier).onNameChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ProfileTextStyle.rowValueMuted.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: ProfileTextStyle.rowValueMuted,
            ),
          ),
        ],
      ),
    );
  }
}

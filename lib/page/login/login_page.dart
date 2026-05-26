import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_config.dart';
import '../../core/app_logger.dart';
import '../../core/app_flavor.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import 'login_provider.dart';
import 'login_theme.dart';
import 'widget/login_sign_in_button.dart';
import 'widget/login_switch_device_dialog.dart';
import 'widget/login_scaffold.dart';
import 'widget/login_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    void refresh() {
      if (mounted) {
        ref.read(loginNotifierProvider.notifier).clearFieldErrors();
        setState(() {});
      }
    }
    _idController.addListener(refresh);
    _passwordController.addListener(refresh);
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openForgot() async {
    final flavor = ref.read(appFlavorProvider);
    final uri = Uri.parse('${AppConfig.webPortalBaseUrl(flavor)}#/auth/resetpassword');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppLog.info('Forgot password: no handler for $uri', tag: 'Login');
      }
    } on PlatformException catch (e, st) {
      AppLog.error(
        'Forgot password launch failed',
        tag: 'Login',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _goHome() async {
    if (!mounted) return;
    context.go(AppRoute.home.path);
  }

  Future<void> _submit() async {
    final identifier = _idController.text.trim();
    final password = _passwordController.text;
    final notifier = ref.read(loginNotifierProvider.notifier);

    var result = await notifier.signIn(identifier: identifier, password: password);
    if (!mounted) return;
    if (result == null) {
      await showApiFailedDialog(
        context,
        title: 'Sign in failed',
        message: 'Invalid username / password',
      );
      notifier.clearFieldErrors();
      return;
    }

    final switchInfo = result.switchDevice;
    if (switchInfo != null) {
      final proceed = await showLoginSwitchDeviceDialog(context, info: switchInfo);
      if (!mounted) return;
      if (proceed != true) {
        await notifier.cancelPendingSwitchDevice();
        return;
      }
      // TEMPORARY: Proceed re-login (`is_proceed`) disabled — use first login session.
      // result = await notifier.confirmSwitchDevice(
      //   identifier: identifier,
      //   password: password,
      // );
      // if (!mounted) return;
      // if (result == null) {
      //   final msg = ref.read(loginNotifierProvider).apiError;
      //   if (msg != null) {
      //     await showApiFailedDialog(context, message: msg, title: 'Sign in failed');
      //   }
      //   return;
      // }
      // if (result.switchDevice != null) {
      //   await showApiFailedDialog(
      //     context,
      //     message: 'Unable to continue login on this device.',
      //     title: 'Sign in failed',
      //   );
      //   await notifier.cancelPendingSwitchDevice();
      //   return;
      // }
    }

    await _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(loginNotifierProvider);
    final fieldHeight = LoginScaffold.oneLineFieldHeight(context);
    final canSubmit = !ui.loading &&
        _idController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;

    return ModalProgressHud(
      inAsyncCall: ui.loading,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          resizeToAvoidBottomInset: true,
          body: LoginScaffold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Email or Phone Number', style: LoginTheme.label(context)),
                SizedBox(height: 10.h),
                SizedBox(
                  height: fieldHeight,
                  child: LoginTextField(
                    controller: _idController,
                    hint: 'Email or phone number',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(height: 15.h),
                Text('Password', style: LoginTheme.label(context)),
                SizedBox(height: 10.h),
                SizedBox(
                  height: fieldHeight,
                  child: LoginTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (canSubmit) _submit();
                    },
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColor.white,
                      ),
                      style: IconButton.styleFrom(foregroundColor: AppColor.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _openForgot,
                  child: Text('Forgot Password?', style: LoginTheme.link(context)),
                ),
                SizedBox(height: 30.h),
                LoginSignInButton(
                  enabled: canSubmit,
                  absorbing: ui.loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

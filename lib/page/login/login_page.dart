import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_config.dart';
import '../../core/app_logger.dart';
import '../../core/app_flavor.dart';
import '../../core/auth_prefs.dart';
import '../../router/app_route.dart';
import '../../theme/app_color.dart';
import '../../widget/modal_progress_hud.dart';
import 'login_provider.dart';
import 'login_theme.dart';
import 'widget/login_region_field.dart';
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
  String? _region;
  var _obscurePassword = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openForgot() async {
    if (_region == null || _region!.isEmpty) {
      ref.read(loginNotifierProvider.notifier).requireRegion();
      return;
    }
    await AuthPrefs.setRegionCode(_region!);
    final flavor = ref.read(appFlavorProvider);
    // Same as Android LoginActivity: BASE_WEB_URL + "#/auth/resetpassword"
    final uri = Uri.parse('${AppConfig.webPortalBaseUrl(flavor)}#/auth/resetpassword');
    // Avoid canLaunchUrl: its Pigeon channel can throw PlatformException(channel-error) on Android.
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

  Future<void> _submit() async {
    final ok = await ref.read(loginNotifierProvider.notifier).signIn(
          identifier: _idController.text.trim(),
          password: _passwordController.text,
          regionCode: _region ?? '',
        );
    if (!mounted || !ok) return;
    context.go(AppRoute.home.path);
  }

  @override
  Widget build(BuildContext context) {
    final ui = ref.watch(loginNotifierProvider);
    final fieldHeight = LoginScaffold.oneLineFieldHeight(context);

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
                Text('Region', style: LoginTheme.label(context)),
                SizedBox(height: 10.h),
                SizedBox(
                  height: fieldHeight,
                  child: LoginRegionField(
                    value: _region,
                    onChanged: (v) => setState(() => _region = v),
                    onClearError: ref.read(loginNotifierProvider.notifier).clearFieldErrors,
                  ),
                ),
                SizedBox(height: 15.h),
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
                    onSubmitted: (_) => _submit(),
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
                if (ui.fieldError == 'region')
                  Text(
                    'Please select your region',
                    textAlign: TextAlign.center,
                    style: LoginTheme.error(context),
                  ),
                if (ui.fieldError == 'credentials' || ui.apiError != null)
                  Text(
                    ui.apiError ?? 'Invalid username / password',
                    textAlign: TextAlign.center,
                    style: LoginTheme.error(context),
                  ),
                SizedBox(height: 30.h),
                SizedBox(
                  height: 56.h,
                  child: FilledButton(
                    onPressed: ui.loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColor.white,
                      foregroundColor: AppColor.loginScreenBlue,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text('Sign In', style: LoginTheme.buttonLabel(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

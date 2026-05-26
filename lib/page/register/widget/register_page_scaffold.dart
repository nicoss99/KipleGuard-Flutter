import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_color.dart';
import 'register_styled_header.dart';

/// Wraps a register page with primary status bar styling, the styled header, and a body region.
class RegisterPageScaffold extends StatelessWidget {
  const RegisterPageScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.trailing,
    this.background,
    this.bottom,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;
  final Widget? trailing;
  final Color? background;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColor.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: background ?? AppColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegisterStyledHeader(title: title, onBack: onBack, trailing: trailing),
            Expanded(child: child),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

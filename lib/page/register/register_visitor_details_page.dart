import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_route.dart';
import '../../theme/app_text_style.dart';
import 'register_strings.dart';
import 'register_visitor_draft.dart';
import 'widget/register_gradient_button.dart';
import 'widget/register_page_scaffold.dart';
import 'widget/register_visitor_form.dart';

/// Android `activity_addvisitor.xml` — white header, underline fields, gradient [Add].
class RegisterVisitorDetailsPage extends StatefulWidget {
  const RegisterVisitorDetailsPage({super.key, required this.args});

  final RegisterVisitorDetailsArgs args;

  @override
  State<RegisterVisitorDetailsPage> createState() => _RegisterVisitorDetailsPageState();
}

class _RegisterVisitorDetailsPageState extends State<RegisterVisitorDetailsPage> {
  final _ic = TextEditingController();
  final _name = TextEditingController();
  final _car = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _temp = TextEditingController();
  final _company = TextEditingController();

  late final List<TextEditingController> _all = [_ic, _name, _car, _mobile, _email, _temp, _company];

  void _onFieldChanged() => setState(() {});

  static const _mobilePrefix = '+60';

  @override
  void initState() {
    super.initState();
    final i = widget.args.initial;
    if (i != null) {
      _ic.text = i.icPassport;
      _name.text = i.name;
      _car.text = i.carPlate;
      _mobile.text = i.mobile.isEmpty ? _mobilePrefix : i.mobile;
      _email.text = i.email;
      _temp.text = i.temperature;
      _company.text = i.company;
    } else {
      _mobile.text = _mobilePrefix;
    }
    _mobile.selection = TextSelection.collapsed(offset: _mobile.text.length);
    for (final c in _all) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  bool get _canAdd {
    if (_name.text.trim().isEmpty) return false;
    final mobile = _mobile.text.trim();
    if (mobile.isEmpty || mobile == _mobilePrefix) return false;
    if (widget.args.lprRequired && _car.text.trim().isEmpty) return false;
    return true;
  }

  Future<void> _openScan() async {
    final r = await context.push<RegisterIdScanResult>(AppRoute.registerIdScan.path);
    if (!mounted || r == null) return;
    setState(() {
      if (r.ic12 != null && r.ic12!.isNotEmpty) _ic.text = r.ic12!;
      if (r.name != null && r.name!.isNotEmpty) _name.text = r.name!;
    });
  }

  void _carInfoTap() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(RegisterStrings.carPlateField, style: AppTextStyle.subtitle),
        content: Text(RegisterStrings.carRecurringHint, style: AppTextStyle.body),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  void _save() {
    context.pop(
      RegisterVisitorDraft(
        name: _name.text,
        mobile: _mobile.text,
        email: _email.text,
        company: widget.args.officeEnvironment ? _company.text : '',
        carPlate: _car.text,
        icPassport: _ic.text,
        temperature: _temp.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterPageScaffold(
      title: RegisterStrings.visitorDetailsTitle,
      onBack: () => context.pop(),
      bottom: Opacity(
        opacity: _canAdd ? 1.0 : 0.4,
        child: IgnorePointer(
          ignoring: !_canAdd,
          child: RegisterGradientButton(label: RegisterStrings.addVisitorCta, onPressed: _save),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: RegisterVisitorForm(
          icController: _ic,
          nameController: _name,
          carController: _car,
          mobileController: _mobile,
          emailController: _email,
          tempController: _temp,
          companyController: _company,
          officeEnvironment: widget.args.officeEnvironment,
          onScanIc: _openScan,
          onCarInfo: _carInfoTap,
        ),
      ),
    );
  }
}

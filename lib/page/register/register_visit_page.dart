import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../../router/app_route.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import 'register_models.dart';
import 'register_repository.dart';
import 'register_strings.dart';
import 'register_visit_data_loader.dart';
import 'register_visit_schedule_helpers.dart';
import 'register_visit_submit.dart';
import 'register_visit_type_policy.dart';
import 'register_visitor_draft.dart';
import 'widget/register_page_scaffold.dart';
import 'widget/register_visit_details_body.dart';

/// Android `CreateVisitActivity` + submit via `RegisterStep3HSAActivity`.
class RegisterVisitPage extends ConsumerStatefulWidget {
  const RegisterVisitPage({super.key, required this.residenceUuid});

  final String residenceUuid;

  @override
  ConsumerState<RegisterVisitPage> createState() => _RegisterVisitPageState();
}

class _RegisterVisitPageState extends ConsumerState<RegisterVisitPage> {
  final _pass = TextEditingController();

  RegisterVisitorTypeOption? _selectedType;
  RegisterUnitOption? _unit;
  RegisterHostOption? _host;
  List<RegisterVisitorTypeOption> _apiTypes = [];
  List<RegisterUnitOption> _units = [];
  List<RegisterHostOption> _hosts = [];
  RegisterVisitorDraft? _visitor;
  final List<XFile> _photos = [];

  DateTime _visitStartUtc = DateTime.now().toUtc();
  DateTime? _visitEndUtc;

  var _lprRequired = false;
  var _officeEnvironment = false;
  var _snapLprEnabled = false;

  bool _loading = true;
  bool _submitting = false;
  String? _loadError;

  bool get _hostsNeedPick => _hosts.isNotEmpty;

  bool get _allowDaysError {
    final t = _selectedType;
    if (t == null) return false;
    return !isVisitorTypeAllowedOnDate(t, _visitStartUtc.toLocal());
  }

  bool get _canSubmit {
    if (_selectedType == null || _unit == null || _allowDaysError) return false;
    if (_hostsNeedPick && _host == null) return false;
    final v = _visitor;
    if (v == null || v.name.trim().isEmpty || v.mobile.trim().isEmpty) return false;
    if (_lprRequired && v.carPlate.trim().isEmpty) return false;
    if (_pass.text.trim().isEmpty) return false;
    if (_photos.isEmpty) return false;
    final end = _visitEndUtc;
    if (end != null && !end.isAfter(_visitStartUtc)) return false;
    return true;
  }

  void _recomputeEndFromPolicy() {
    final t = _selectedType;
    if (t == null) {
      _visitEndUtc = null;
      return;
    }
    _visitEndUtc = computeDefaultEndUtc(type: t, startUtc: _visitStartUtc);
  }

  @override
  void initState() {
    super.initState();
    _pass.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.residenceUuid.isEmpty) {
        await showApiFailedDialog(context, message: 'Invalid residence');
        if (!mounted) return;
        context.pop();
      }
    });
    _bootstrap();
  }

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final snap = await DashboardPrefs.loadSnapshot();
      final data = await loadRegisterVisitData(
        ref,
        widget.residenceUuid,
        officeMode: snap.officeEnvironment,
      );
      if (!mounted) return;
      setState(() {
        _apiTypes = data.types;
        _units = data.units;
        _snapLprEnabled = snap.lprEnabled;
        _officeEnvironment = snap.officeEnvironment;
        _visitStartUtc = DateTime.now().toUtc();
        _selectedType = data.types.length == 1 ? data.types.first : null;
        _recomputeEndFromPolicy();
        _lprRequired = _snapLprEnabled && (_selectedType?.isLprEnabled == true);
        _loading = false;
        if (data.units.length == 1) {
          _unit = data.units.first;
          _loadHostsForUnit(_unit!.unitUuid);
        }
      });
    } catch (e, st) {
      AppLog.error('Register visit load failed', tag: 'Register', error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'Could not load form';
        });
      }
    }
  }

  Future<void> _loadHostsForUnit(String unitUuid) async {
    try {
      final hosts = await ref.read(registerRepositoryProvider).fetchHostsForUnit(
        residenceUuid: widget.residenceUuid,
        unitUuid: unitUuid,
      );
      if (!mounted) return;
      setState(() {
        _hosts = hosts;
        _host = null;
      });
    } catch (e, st) {
      AppLog.error('Unit members failed', tag: 'Register', error: e, stackTrace: st);
      if (mounted) {
        setState(() => _hosts = []);
        await showApiFailedDialog(context, error: e);
      }
    }
  }

  Future<void> _openVisitorEditor() async {
    final draft = await context.push<RegisterVisitorDraft>(
      AppRoute.registerVisitorDetails.path,
      extra: RegisterVisitorDetailsArgs(
        lprRequired: _lprRequired,
        officeEnvironment: _officeEnvironment,
        initial: _visitor,
      ),
    );
    if (!mounted || draft == null) return;
    setState(() => _visitor = draft);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= RegisterStrings.maxVisitPhotos) {
      if (mounted) {
        await showApiFailedDialog(context, message: RegisterStrings.photoMaxReached);
      }
      return;
    }
    final x = await ImagePicker().pickImage(source: source, imageQuality: 72);
    if (x != null && mounted) {
      setState(() {
        _photos.add(x);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _pickVisitStart() async {
    final r = await pickVisitUtcFromSheet(context, initialUtc: _visitStartUtc);
    if (!mounted || r == null) return;
    setState(() {
      _visitStartUtc = r;
      _recomputeEndFromPolicy();
    });
  }

  Future<void> _pickVisitEnd() async {
    final r = await pickVisitUtcFromSheet(context, initialUtc: _visitEndUtc ?? _visitStartUtc);
    if (!mounted || r == null) return;
    setState(() => _visitEndUtc = r);
  }

  void _clearVisitEnd() => setState(_recomputeEndFromPolicy);

  Future<void> _submit() async {
    final type = _selectedType;
    final unit = _unit;
    final visitor = _visitor;
    if (type == null || unit == null || visitor == null || !_canSubmit) {
      await showApiFailedDialog(context, message: RegisterStrings.errorRequired);
      return;
    }

    setState(() => _submitting = true);
    try {
      await submitRegisterVisit(
        ref: ref,
        context: context,
        residenceUuid: widget.residenceUuid,
        type: type,
        unit: unit,
        host: _host,
        visitor: visitor,
        passReference: _pass.text,
        visitPhotos: List<XFile>.from(_photos),
      );
    } catch (e, st) {
      if (!mounted) return;
      await handleRegisterSubmitError(context, e, st);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onTypeChanged(RegisterVisitorTypeOption? v) {
    setState(() {
      _selectedType = v;
      _lprRequired = _snapLprEnabled && (v?.isLprEnabled == true);
      _recomputeEndFromPolicy();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.residenceUuid.isEmpty) {
      return RegisterPageScaffold(
        title: RegisterStrings.visitDetailsTitle,
        onBack: () => context.pop(),
        child: Center(child: Text('Invalid residence', style: AppTextStyle.body)),
      );
    }
    return ModalProgressHud(
      inAsyncCall: _loading || _submitting,
      child: RegisterPageScaffold(
        title: RegisterStrings.visitDetailsTitle,
        onBack: () => context.pop(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: _bodyChild(),
        ),
      ),
    );
  }

  Widget _bodyChild() {
    if (_loadError != null) {
      return KeyedSubtree(
        key: const ValueKey('error'),
        child: Center(child: Text(_loadError!, style: AppTextStyle.body)),
      );
    }
    if (_loading) {
      return const KeyedSubtree(key: ValueKey('loading'), child: SizedBox.shrink());
    }
    return KeyedSubtree(
      key: const ValueKey('loaded'),
      child: RegisterVisitDetailsBody(
        apiTypes: _apiTypes,
        selectedType: _selectedType,
        onTypeChanged: (v) => _onTypeChanged(v),
        allowDaysError: _allowDaysError,
        visitStartText: formatVisitDisplayUtc(_visitStartUtc),
        visitEndText: _visitEndUtc == null ? '' : formatVisitDisplayUtc(_visitEndUtc!),
        onPickVisitStart: _pickVisitStart,
        onPickVisitEnd: _pickVisitEnd,
        onClearVisitEnd: _clearVisitEnd,
        units: _units,
        selectedUnit: _unit,
        onUnitChanged: (v) {
          setState(() {
            _unit = v;
            _host = null;
            _hosts = [];
          });
          if (v != null) _loadHostsForUnit(v.unitUuid);
        },
        hosts: _hosts,
        selectedHost: _host,
        onHostChanged: (v) => setState(() => _host = v),
        visitor: _visitor,
        onAddVisitor: _openVisitorEditor,
        onEditVisitor: _openVisitorEditor,
        onClearVisitor: () => setState(() => _visitor = null),
        visitPhotos: _photos,
        onPickCamera: () => _pickImage(ImageSource.camera),
        onPickGallery: () => _pickImage(ImageSource.gallery),
        onRemovePhoto: _removePhoto,
        passController: _pass,
        onSubmit: _submit,
        canSubmit: _canSubmit,
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_style.dart';
import '../../widget/modal_progress_hud.dart';
import 'reporting_models.dart';
import 'reporting_prefs.dart';
import 'reporting_repository.dart';
import 'reporting_strings.dart';
import 'reporting_submit_service.dart';
import 'widget/reporting_category_field.dart';
import 'widget/reporting_category_sheet.dart';
import 'widget/reporting_datetime_field.dart';
import 'widget/reporting_description_field.dart';
import 'widget/reporting_page_header.dart';
import 'widget/reporting_photo_strip.dart';
import 'widget/reporting_success_dialog.dart';

/// Android `ReportingStep2Activity` + dashboard incident API pipeline.
class ReportingFormPage extends ConsumerStatefulWidget {
  const ReportingFormPage({super.key, required this.args});

  final ReportingFormArgs args;

  @override
  ConsumerState<ReportingFormPage> createState() => _ReportingFormPageState();
}

class _ReportingFormPageState extends ConsumerState<ReportingFormPage> {
  final _desc = TextEditingController();
  final _descFocus = FocusNode();
  final _picker = ImagePicker();
  var _loadingCats = true;
  var _submitting = false;
  List<ReportingCategory> _cats = [];
  String? _selectedUuid;
  String _dateLabel = '';
  String _incidentUtc = '';
  double _lat = 0;
  double _lng = 0;
  var _firstSpinner = true;
  final _files = <XFile>[];
  var _errDesc = false;
  var _errDate = false;
  var _errCat = false;

  bool get _canSubmit =>
      (_selectedUuid?.isNotEmpty ?? false) &&
      _desc.text.trim().isNotEmpty &&
      _incidentUtc.isNotEmpty;

  String? get _categoryName {
    if (_selectedUuid == null) return null;
    for (final c in _cats) {
      if (c.uuid == _selectedUuid) return c.name;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    AppLog.track('incidents_view', screen: 'ReportingForm');
    _desc.addListener(_onFormChanged);
    _init();
  }

  void _onFormChanged() {
    if (mounted) setState(() => _errDesc = false);
  }

  Future<void> _init() async {
    await _location();
    await _loadCategories();
  }

  Future<void> _location() async {
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      _lat = pos.latitude;
      _lng = pos.longitude;
    } catch (_) {}
  }

  List<ReportingCategory> _parseCats(String raw) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final r = m['resource'];
      if (r is! List<dynamic>) return [];
      return r
          .map((e) => e is Map<String, dynamic> ? e : null)
          .whereType<Map<String, dynamic>>()
          .map((e) => ReportingCategory(uuid: '${e['uuid'] ?? ''}', name: '${e['name'] ?? ''}'))
          .where((e) => e.uuid.isNotEmpty && e.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadCategories() async {
    final snap = await DashboardPrefs.loadSnapshot();
    final cached = await ReportingPrefs.readIncidentCategories(snap.residenceId);
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _cats = _parseCats(cached);
        _loadingCats = false;
      });
    }
    try {
      final raw = await ref.read(reportingRepositoryProvider).fetchIncidentCategoriesRaw();
      await ReportingPrefs.writeIncidentCategories(snap.residenceId, raw);
      if (!mounted) return;
      setState(() {
        _cats = _parseCats(raw);
        _loadingCats = false;
      });
    } catch (e, st) {
      AppLog.error('Incident categories', tag: 'Reporting', error: e, stackTrace: st);
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  Future<void> _onPullRefresh() async {
    AppLog.track('reporting_pull_refresh', screen: 'ReportingForm');
    final sw = Stopwatch()..start();
    try {
      await _loadCategories();
    } finally {
      final left = const Duration(seconds: 6) - sw.elapsed;
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
  }

  ThemeData _pickerTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: AppColor.primary, onPrimary: AppColor.white),
      dialogTheme: DialogThemeData(backgroundColor: AppColor.white),
    );
  }

  Future<void> _pickDateTime() async {
    AppLog.track('select_datetime', screen: 'ReportingForm');
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: ReportingStrings.reportDateTime,
      cancelText: ReportingStrings.cancel,
      confirmText: ReportingStrings.pickerOk,
      builder: (ctx, child) => Theme(data: _pickerTheme(ctx), child: child!),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      helpText: ReportingStrings.reportDateTime,
      cancelText: ReportingStrings.cancel,
      confirmText: ReportingStrings.pickerOk,
      builder: (ctx, child) => Theme(data: _pickerTheme(ctx), child: child!),
    );
    if (t == null || !mounted) return;
    var picked = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (picked.isAfter(now)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ReportingStrings.errorReportDate)),
      );
      await _pickDateTime();
      return;
    }
    setState(() {
      _dateLabel = DateFormat('dd MMM yyyy - hh:mm aa', 'en_US').format(picked);
      _incidentUtc = DateFormat('yyyy-MM-dd HH:mm:ss').format(picked.toUtc());
      _errDate = false;
    });
  }

  Future<void> _openCategorySheet() async {
    if (_cats.isEmpty) return;
    final uuid = await showReportingCategorySheet(
      context,
      categories: _cats,
      selectedUuid: _selectedUuid,
    );
    if (uuid == null || !mounted) return;
    setState(() {
      _selectedUuid = uuid;
      _errCat = false;
      if (!_firstSpinner) _descFocus.requestFocus();
      _firstSpinner = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_files.length >= ReportingPhotoStrip.maxPhotos) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ReportingStrings.imageLimit)),
        );
      }
      return;
    }
    if (source == ImageSource.camera) {
      AppLog.track('add_photo', screen: 'ReportingForm');
      final st = await Permission.camera.request();
      if (!st.isGranted) return;
    }
    final img = await _picker.pickImage(source: source, imageQuality: 72);
    if (img != null && mounted) setState(() => _files.add(img));
  }

  Future<void> _pickGallery() async {
    AppLog.track('add_photo', screen: 'ReportingForm');
    final limit = ReportingPhotoStrip.maxPhotos - _files.length;
    if (limit <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ReportingStrings.imageLimit)),
        );
      }
      return;
    }
    final imgs = await _picker.pickMultiImage(limit: limit);
    if (mounted) setState(() => _files.addAll(imgs));
  }

  Future<void> _submit() async {
    if (!_canSubmit || _submitting) return;

    final desc = _desc.text.trim();
    setState(() {
      _errDesc = desc.isEmpty;
      _errDate = _incidentUtc.isEmpty;
      _errCat = _selectedUuid == null || _selectedUuid!.isEmpty;
    });
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ReportingStrings.errorBlank)),
      );
      return;
    }

    AppLog.track('submit_incident', screen: 'ReportingForm');
    setState(() => _submitting = true);

    final snap = await DashboardPrefs.loadSnapshot();
    final body = <String, dynamic>{
      'incident_date': _incidentUtc,
      'residence_uuid': snap.residenceId,
      'category_uuid': _selectedUuid,
      'kg_guard_uuid': widget.args.guardUuid,
      'security_company_uuid': widget.args.companyUuid,
      'lat': _lat,
      'lng': _lng,
      'description': desc,
      'status': 'PENDING',
      'pin': widget.args.guardPin,
    };
    final paths = _files.map((e) => e.path).toList();
    final categoryName = _categoryName ?? '';

    try {
      final outcome = await ref.read(reportingSubmitServiceProvider).submit(
            body: body,
            imagePaths: paths,
          );
      if (!mounted) return;
      await showReportingSuccessDialog(
        context,
        categoryName: categoryName,
        dateLabel: _dateLabel,
        photoCount: _files.length,
        queuedOffline: outcome == ReportingSubmitOutcome.queued,
      );
      if (!mounted) return;
      context.pop();
    } catch (e, st) {
      AppLog.error('Incident submit', tag: 'Reporting', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ReportingStrings.submitFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _desc.removeListener(_onFormChanged);
    _desc.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: ModalProgressHud(
        inAsyncCall: _submitting,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            children: [
              ReportingPageHeader(title: ReportingStrings.reportIncident),
              Expanded(
                child: RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: _onPullRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 16.h),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReportingCategoryField(
                              label: ReportingStrings.reportType,
                              loading: _loadingCats,
                              categories: _cats,
                              selectedUuid: _selectedUuid,
                              error: _errCat,
                              onTap: _openCategorySheet,
                            ),
                            SizedBox(height: 20.h),
                            ReportingDescriptionField(
                              label: ReportingStrings.reportDesc,
                              hint: ReportingStrings.reportDetails,
                              controller: _desc,
                              focusNode: _descFocus,
                              error: _errDesc,
                              onChanged: (_) => setState(() => _errDesc = false),
                            ),
                            SizedBox(height: 20.h),
                            ReportingDateTimeField(
                              label: ReportingStrings.reportDateTime,
                              hint: ReportingStrings.reportDateTimeHint,
                              value: _dateLabel,
                              error: _errDate,
                              onTap: _pickDateTime,
                            ),
                          ],
                        ),
                      ),
                      ReportingPhotoStrip(
                        photos: _files,
                        onPickCamera: () => _pickImage(ImageSource.camera),
                        onPickGallery: _pickGallery,
                        onRemoveAt: (i) => setState(() => _files.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        disabledBackgroundColor: AppColor.greyBorder,
                        disabledForegroundColor: AppColor.textSecondary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: _canSubmit && !_submitting ? _submit : null,
                      child: Text(
                        ReportingStrings.reportSubmit,
                        style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
                      ),
                    ),
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

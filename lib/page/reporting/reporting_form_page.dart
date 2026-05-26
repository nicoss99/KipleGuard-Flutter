import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_logger.dart';
import '../../core/cache/app_cache_store.dart';
import '../../core/cache/guard_cache_keys.dart';
import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_calendar_picker.dart';
import '../../widget/modal_progress_hud.dart';
import 'reporting_models.dart';
import 'reporting_parsers.dart';
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
  String? _selectedKey;
  String _dateLabel = '';
  String _incidentAt = '';
  var _firstSpinner = true;
  final _files = <XFile>[];
  var _errDesc = false;
  var _errDate = false;
  var _errCat = false;

  bool get _canSubmit =>
      (_selectedKey?.isNotEmpty ?? false) &&
      _desc.text.trim().isNotEmpty &&
      _incidentAt.isNotEmpty;

  String? get _categoryLabel {
    if (_selectedKey == null) return null;
    for (final c in _cats) {
      if (c.key == _selectedKey) return c.label;
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
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      if (mounted) setState(() => _loadingCats = false);
      return;
    }
    final cached = await ReportingPrefs.readIncidentCategories(snap.residenceId);
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _cats = parseIncidentTypesCache(cached);
        _loadingCats = false;
      });
    }
    try {
      final types = await ref
          .read(reportingRepositoryProvider)
          .fetchIncidentTypes(snap.residenceId);
      await ReportingPrefs.writeIncidentCategories(
        snap.residenceId,
        encodeIncidentTypesCache(types),
      );
      await AppCacheStore.write(
        GuardCacheKeys.incidentTypes(snap.residenceId),
        <String, dynamic>{
          'items': types.map((t) => <String, dynamic>{'key': t.key, 'label': t.label}).toList(),
        },
      );
      if (!mounted) return;
      setState(() {
        _cats = types;
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

  Future<void> _pickDateTime() async {
    AppLog.track('select_datetime', screen: 'ReportingForm');
    final now = DateTime.now();
    var picked = await AppCalendarPicker.showDayAndTime(
      context: context,
      initial: now,
      lastDate: now,
      helpText: ReportingStrings.reportDateTime,
      cancelText: ReportingStrings.cancel,
      confirmText: ReportingStrings.pickerOk,
    );
    if (picked == null || !mounted) return;
    if (picked.isAfter(now)) {
      if (!mounted) return;
      await showApiFailedDialog(context, message: ReportingStrings.errorReportDate);
      await _pickDateTime();
      return;
    }
    setState(() {
      _dateLabel = DateFormat('dd MMM yyyy - hh:mm aa', 'en_US').format(picked);
      _incidentAt = DateFormat('yyyy-MM-dd hh:mm aa', 'en_US').format(picked);
      _errDate = false;
    });
  }

  Future<void> _openCategorySheet() async {
    if (_cats.isEmpty) return;
    final key = await showReportingCategorySheet(
      context,
      categories: _cats,
      selectedKey: _selectedKey,
    );
    if (key == null || !mounted) return;
    setState(() {
      _selectedKey = key;
      _errCat = false;
      if (!_firstSpinner) _descFocus.requestFocus();
      _firstSpinner = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_files.length >= ReportingPhotoStrip.maxPhotos) {
      if (mounted) {
        await showApiFailedDialog(context, message: ReportingStrings.imageLimit);
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
        await showApiFailedDialog(context, message: ReportingStrings.imageLimit);
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
      _errDate = _incidentAt.isEmpty;
      _errCat = _selectedKey == null || _selectedKey!.isEmpty;
    });
    if (!_canSubmit) {
      await showApiFailedDialog(context, message: ReportingStrings.errorBlank);
      return;
    }

    AppLog.track('submit_incident', screen: 'ReportingForm');
    setState(() => _submitting = true);

    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      if (mounted) {
        await showApiFailedDialog(context, message: ReportingStrings.errorBlank);
        setState(() => _submitting = false);
      }
      return;
    }
    final paths = _files.map((e) => e.path).toList();
    final categoryName = _categoryLabel ?? '';

    try {
      final outcome = await ref.read(reportingSubmitServiceProvider).submit(
            residenceUuid: snap.residenceId,
            incidentType: _selectedKey!,
            description: desc,
            incidentAt: _incidentAt,
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
      if (mounted) await showApiFailedDialog(context, error: e);
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
                              selectedKey: _selectedKey,
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

import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/app_logger.dart';
import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_style.dart';
import 'reporting_models.dart';
import 'reporting_prefs.dart';
import 'reporting_repository.dart';
import 'reporting_strings.dart';
import 'reporting_sync_service.dart';
import 'widget/reporting_category_icon.dart';
import 'widget/reporting_page_header.dart';

/// Android `ReportingStep2Activity` + `activity_reportingstep2.xml`.
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

  @override
  void initState() {
    super.initState();
    AppLog.track('incidents_view', screen: 'ReportingForm');
    _init();
  }

  Future<void> _init() async {
    await _location();
    await _loadCategories();
  }

  Future<void> _location() async {
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
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
        _pickDefaultCat();
      });
    }
    try {
      final raw = await ref.read(reportingRepositoryProvider).fetchIncidentCategoriesRaw();
      await ReportingPrefs.writeIncidentCategories(snap.residenceId, raw);
      if (!mounted) return;
      setState(() {
        _cats = _parseCats(raw);
        _loadingCats = false;
        _pickDefaultCat();
      });
    } catch (e, st) {
      AppLog.error('Incident categories', tag: 'Reporting', error: e, stackTrace: st);
      if (mounted) setState(() => _loadingCats = false);
    }
  }

  void _pickDefaultCat() {
    if (_selectedUuid == null && _cats.isNotEmpty) {
      _selectedUuid = _cats.first.uuid;
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
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));
    if (t == null || !mounted) return;
    var picked = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (picked.isAfter(now)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ReportingStrings.errorReportDate)));
      await _pickDateTime();
      return;
    }
    setState(() {
      _dateLabel = DateFormat('dd MMM yyyy - hh:mm aa', 'en_US').format(picked);
      _incidentUtc = DateFormat('yyyy-MM-dd HH:mm:ss').format(picked.toUtc());
      _errDate = false;
    });
  }

  Future<void> _openAddPhoto() async {
    AppLog.track('add_photo', screen: 'ReportingForm');
    final choice = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text(ReportingStrings.camera), onTap: () => Navigator.pop(ctx, 0)),
            ListTile(title: const Text(ReportingStrings.gallery), onTap: () => Navigator.pop(ctx, 1)),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 0) {
      final st = await Permission.camera.request();
      if (!st.isGranted) return;
      final img = await _picker.pickImage(source: ImageSource.camera);
      if (img != null && mounted && _files.length < 5) setState(() => _files.add(img));
    } else {
      final limit = 5 - _files.length;
      if (limit <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ReportingStrings.imageLimit)));
        return;
      }
      final imgs = await _picker.pickMultiImage(limit: limit);
      if (mounted) setState(() => _files.addAll(imgs));
    }
  }

  Future<void> _submit() async {
    AppLog.track('submit_incident', screen: 'ReportingForm');
    final desc = _desc.text.trim();
    final pass = desc.isNotEmpty && _incidentUtc.isNotEmpty && (_selectedUuid?.isNotEmpty ?? false);
    setState(() {
      _errDesc = desc.isEmpty;
      _errDate = _incidentUtc.isEmpty;
      _errCat = _selectedUuid == null || _selectedUuid!.isEmpty;
    });
    if (!pass) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ReportingStrings.errorBlank)));
      return;
    }
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
    await ReportingPrefs.enqueue(body: body, imagePaths: _files.map((e) => e.path).toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ReportingStrings.reportSaved)));
    unawaited(ref.read(reportingSyncServiceProvider).processQueue());
    context.pop();
  }

  @override
  void dispose() {
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
                  padding: EdgeInsets.only(bottom: 100.h),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(ReportingStrings.reportType, error: _errCat),
                          SizedBox(height: 4.h),
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.all(5.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            child: _loadingCats
                                ? Padding(padding: EdgeInsets.all(16.w), child: const LinearProgressIndicator())
                                : Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _selectedUuid != null && _cats.any((c) => c.uuid == _selectedUuid)
                                            ? _selectedUuid
                                            : null,
                                        hint: const Text(''),
                                        items: _cats
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c.uuid,
                                                child: Row(
                                                  children: [
                                                    reportingCategoryIcon(
                                                      c.name,
                                                      selected: c.uuid == _selectedUuid,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Expanded(child: Text(c.name, style: AppTextStyle.subtitle)),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          setState(() {
                                            _selectedUuid = v;
                                            _errCat = false;
                                            if (!_firstSpinner) {
                                              _descFocus.requestFocus();
                                            }
                                            _firstSpinner = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                          SizedBox(height: 20.h),
                          _label(ReportingStrings.reportDesc, error: _errDesc),
                          TextField(
                            controller: _desc,
                            focusNode: _descFocus,
                            maxLines: 5,
                            style: AppTextStyle.subtitle,
                            decoration: InputDecoration(
                              hintText: ReportingStrings.reportDetails,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10.w),
                            ),
                            onChanged: (_) => setState(() => _errDesc = false),
                          ),
                          Container(height: 1, margin: EdgeInsets.symmetric(horizontal: 5.w), color: _lineDesc),
                          SizedBox(height: 20.h),
                          _label(ReportingStrings.reportDateTime, error: _errDate),
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.all(5.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            child: InkWell(
                              onTap: _pickDateTime,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10.w),
                                color: AppColor.lightGreyBar,
                                child: Text(
                                  _dateLabel.isEmpty ? ReportingStrings.reportDateTimeHint : _dateLabel,
                                  style: AppTextStyle.subtitle.copyWith(
                                    color: _dateLabel.isEmpty ? AppColor.textSecondary : AppColor.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                      child: Text(ReportingStrings.reportAddPhoto, style: _sectionStyle),
                    ),
                    SizedBox(
                      height: 140.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        children: [
                          if (_files.length < 5) _addTile(),
                          ..._files.asMap().entries.map((e) => _thumbTile(e.key, e.value)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.all(20.w),
                  ),
                  onPressed: _submit,
                  child: Text(
                    ReportingStrings.reportSubmit,
                    style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _lineDesc => _errDesc ? AppColor.red : AppColor.greyBorder;

  TextStyle get _sectionStyle => AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600);

  Widget _label(String t, {bool error = false}) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Text(t, style: _sectionStyle.copyWith(color: error ? AppColor.red : AppColor.textPrimary)),
    );
  }

  Widget _addTile() {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openAddPhoto,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColor.greyBorder, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/android/drawable/ic_register_upload.xml',
                  width: 28.w,
                  height: 28.h,
                  colorFilter: const ColorFilter.mode(AppColor.textSecondary, BlendMode.srcIn),
                ),
                SizedBox(height: 4.h),
                Text(ReportingStrings.addPhoto, style: AppTextStyle.body.copyWith(fontSize: 12.sp)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbTile(int index, XFile f) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: SizedBox(
        width: 120.w,
        height: 120.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (ctx) => Dialog(
                        child: InteractiveViewer(child: Image.file(File(f.path), fit: BoxFit.contain)),
                      ),
                    ),
                    child: Image.file(File(f.path), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/android/drawable/ic_delete.xml',
                  width: 25.w,
                  height: 25.h,
                  colorFilter: const ColorFilter.mode(AppColor.red, BlendMode.srcIn),
                ),
                onPressed: () => setState(() => _files.removeAt(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

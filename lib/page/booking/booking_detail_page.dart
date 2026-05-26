import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_error_message.dart';
import '../../core/dashboard_prefs.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import '../register/register_ic_encrypt.dart';
import 'booking_repository.dart';
import 'booking_strings.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  const BookingDetailPage({super.key, required this.bookingUuid});

  final String bookingUuid;

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  Map<String, dynamic>? _row;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  String _residenceId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No residence selected';
      });
      return;
    }
    try {
      final m = await ref
          .read(bookingRepositoryProvider)
          .fetchBookingDetail(
            residenceUuid: snap.residenceId,
            bookingUuid: widget.bookingUuid,
          );
      setState(() {
        _row = m;
        _residenceId = snap.residenceId;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  String _fmt(String? raw, String pattern) {
    if (raw == null || raw.isEmpty || raw == 'null') return '—';
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseUtc(raw).toLocal();
      return DateFormat(pattern, 'en_US').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _duration(Map<String, dynamic> m) {
    final room = m['rooms_by_room_uuid'];
    if (room is! Map) return '—';
    final h = room['duration_hour'];
    final min = room['duration_min'];
    final hp = h is int ? h : int.tryParse('$h') ?? 0;
    final mp = min is int ? min : int.tryParse('$min') ?? 0;
    if (hp <= 0 && mp <= 0) return '0 h 0 min';
    final parts = <String>[];
    if (hp > 0) parts.add('$hp h');
    if (mp > 0) parts.add('$mp min');
    return parts.join(' ');
  }

  bool _canCheckIn(Map<String, dynamic> m) {
    final last = m['last_scan']?.toString();
    if (last != null && last.isNotEmpty) return false;
    final end = m['end_time']?.toString();
    if (end != null && end.isNotEmpty) {
      try {
        final endMs = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).parseUtc(end).millisecondsSinceEpoch;
        if (endMs < DateTime.now().millisecondsSinceEpoch) return false;
      } catch (_) {}
    }
    final start = m['start_time']?.toString();
    if (start != null && start.isNotEmpty) {
      try {
        final sd = DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parseUtc(start).toLocal());
        final td = DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (sd.compareTo(td) > 0) return false;
      } catch (_) {}
    }
    return true;
  }

  bool _canCheckOut(Map<String, dynamic> m) {
    final last = m['last_scan']?.toString();
    return last == 'IN';
  }

  Future<void> _confirmAndEdit({required bool checkIn}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          checkIn
              ? BookingStrings.confirmCheckIn
              : BookingStrings.confirmCheckOut,
          style: AppTextStyle.subtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(BookingStrings.no, style: AppTextStyle.body),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(BookingStrings.yes),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final now = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now().toUtc());
    setState(() => _submitting = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .editBooking(
            bookingUuid: widget.bookingUuid,
            checkInTimeUtc: checkIn ? now : null,
            checkOutTimeUtc: checkIn ? null : now,
            lastScan: checkIn ? 'IN' : 'OUT',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(BookingStrings.updated)));
      await _load();
    } catch (e) {
      if (mounted) await showApiFailedDialog(context, error: e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _dial(String? raw) async {
    if (raw == null || raw.isEmpty) return;
    var n = raw.trim();
    if (!n.startsWith('0') && !n.startsWith('+')) n = '+$n';
    final u = Uri.parse('tel:$n');
    if (await canLaunchUrl(u)) await launchUrl(u);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: _submitting,
        child: Scaffold(
          backgroundColor: AppColor.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StandardPrimaryHeader(
                title: BookingStrings.detailsTitle,
                onBack: () => context.pop(),
              ),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: AppProgressIndicator(),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: AppTextStyle.body.copyWith(color: AppColor.red),
        ),
      );
    }
    final m = _row;
    if (m == null) {
      return const Center(child: Text('Not found'));
    }

    final prof = m['user_profiles_by_user_profile_uuid'];
    final guestName = prof is Map ? prof['name']?.toString() ?? 'N/A' : 'N/A';
    final guestPhone = prof is Map ? prof['phone']?.toString() : null;

    final types = m['types_by_type_uuid'];
    final category = types is Map ? types['name']?.toString() ?? '' : '';

    final unit = m['residence_units_by_unit_uuid'];
    final unitName = unit is Map ? unit['name']?.toString() ?? 'N/A' : 'N/A';

    final authIcCipher = m['auth_person_ic']?.toString() ?? '';
    final authIc = _residenceId.isNotEmpty
        ? decryptIcForResidence(authIcCipher, _residenceId)
        : authIcCipher;

    final qr = (m['qr_code']?.toString().isNotEmpty == true)
        ? m['qr_code'].toString()
        : (m['uuid']?.toString() ?? '');

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: 200.w,
              height: 200.w,
              child: QrImageView(
                data: qr,
                version: QrVersions.auto,
                gapless: true,
                backgroundColor: AppColor.white,
                padding: EdgeInsets.all(8.w),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _kv(BookingStrings.guest, guestName),
          _kv(BookingStrings.mobile, guestPhone ?? 'N/A'),
          if (guestPhone != null && guestPhone.isNotEmpty)
            TextButton.icon(
              onPressed: () => _dial(guestPhone),
              icon: const Icon(Icons.call_outlined, color: AppColor.primary),
              label: Text(
                BookingStrings.callGuest,
                style: AppTextStyle.subtitle,
              ),
            ),
          _kv(BookingStrings.unit, unitName),
          _kv(BookingStrings.category, category.isEmpty ? '—' : category),
          _kv(BookingStrings.room, m['room_name']?.toString() ?? '—'),
          _kv(BookingStrings.duration, _duration(m)),
          _kv(
            BookingStrings.startTime,
            _fmt(m['start_time']?.toString(), 'dd MMM yyyy, hh:mm a'),
          ),
          _kv(
            BookingStrings.endTime,
            _fmt(m['end_time']?.toString(), 'dd MMM yyyy, hh:mm a'),
          ),
          _kv(
            BookingStrings.submitted,
            _fmt(m['created_at']?.toString(), 'dd MMM yyyy'),
          ),
          _kv(BookingStrings.attendees, m['total_attendee']?.toString() ?? '—'),
          _kv(
            BookingStrings.arrival,
            _fmt(m['check_in_time']?.toString(), 'dd MMM yyyy, hh:mm a'),
          ),
          _kv(
            BookingStrings.exit,
            _fmt(m['check_out_time']?.toString(), 'dd MMM yyyy, hh:mm a'),
          ),
          _kv(
            BookingStrings.authName,
            (m['auth_person_name']?.toString().isNotEmpty ?? false)
                ? m['auth_person_name'].toString()
                : '—',
          ),
          _kv(
            BookingStrings.authContact,
            m['auth_contact_number']?.toString() ?? '—',
          ),
          _kv(BookingStrings.authIc, authIc.isEmpty ? '—' : authIc),
          SizedBox(height: 20.h),
          if (_canCheckIn(m))
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () => _confirmAndEdit(checkIn: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primary,
                minimumSize: Size.fromHeight(48.h),
              ),
              child: Text(BookingStrings.checkIn),
            ),
          if (_canCheckOut(m)) ...[
            SizedBox(height: 10.h),
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () => _confirmAndEdit(checkIn: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.green,
                minimumSize: Size.fromHeight(48.h),
              ),
              child: Text(BookingStrings.checkOut),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              k,
              style: AppTextStyle.bodyMuted.copyWith(fontSize: 13.sp),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

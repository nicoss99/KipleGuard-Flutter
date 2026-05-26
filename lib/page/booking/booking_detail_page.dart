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
import '../../widget/app_success_dialog.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import 'booking_guard_models.dart';
import 'booking_repository.dart';
import 'booking_strings.dart';
import 'guard_booking_repository.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  const BookingDetailPage({super.key, required this.bookingUuid});

  /// Route param — numeric booking id as string.
  final String bookingUuid;

  int get bookingId => int.tryParse(bookingUuid) ?? 0;

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  GuardBookingRow? _booking;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (widget.bookingId <= 0) {
      setState(() {
        _loading = false;
        _error = 'Invalid booking';
      });
      return;
    }
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
      final row = await ref.read(bookingRepositoryProvider).fetchBookingDetail(
            residenceUuid: snap.residenceId,
            bookingId: widget.bookingId,
          );
      setState(() {
        _booking = row;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = apiErrorMessage(e);
      });
    }
  }

  String _displayTime(String? iso, String? label) {
    if (label != null && label.isNotEmpty) return label;
    if (iso == null || iso.isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a', 'en_US')
          .format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  Future<void> _confirmAndSubmit({required bool checkIn}) async {
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
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final now = guardBookingCurrentTime();
      final row = checkIn
          ? await repo.checkIn(
              residenceUuid: snap.residenceId,
              bookingId: widget.bookingId,
              currentTime: now,
            )
          : await repo.checkOut(
              residenceUuid: snap.residenceId,
              bookingId: widget.bookingId,
              currentTime: now,
            );
      if (!mounted) return;
      setState(() => _booking = row);
      await showAppSuccessDialog(
        context,
        message: checkIn
            ? BookingStrings.checkInSuccess
            : BookingStrings.checkOutSuccess,
      );
    } catch (e) {
      if (mounted) await showApiFailedDialog(context, error: e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _dial(String raw) async {
    var n = raw.trim();
    if (n.isEmpty) return;
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
      return const Center(child: AppProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: AppTextStyle.body.copyWith(color: AppColor.red),
        ),
      );
    }
    final b = _booking;
    if (b == null) {
      return const Center(child: Text('Not found'));
    }

    final qr = (b.qrCodeData?.isNotEmpty ?? false)
        ? b.qrCodeData!
        : b.bookingNumber;

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
          _kv(BookingStrings.guest, b.name),
          _kv(BookingStrings.mobile, b.mobileNumber.isEmpty ? '—' : b.mobileNumber),
          if (b.dialPhone.isNotEmpty)
            TextButton.icon(
              onPressed: () => _dial(b.dialPhone),
              icon: const Icon(Icons.call_outlined, color: AppColor.primary),
              label: Text(
                BookingStrings.callGuest,
                style: AppTextStyle.subtitle,
              ),
            ),
          _kv(BookingStrings.unit, b.unitLabel),
          _kv(BookingStrings.category, b.category.isEmpty ? '—' : b.category),
          _kv(BookingStrings.room, b.bookingName),
          _kv(BookingStrings.duration, b.durationLabel),
          _kv(
            BookingStrings.startTime,
            b.etaArrivalLabel ?? '—',
          ),
          _kv(
            BookingStrings.endTime,
            b.etaExitLabel ?? '—',
          ),
          _kv(BookingStrings.submitted, b.submittedDate),
          _kv(
            BookingStrings.attendees,
            b.attendeeCount?.toString() ?? '—',
          ),
          _kv(
            BookingStrings.arrival,
            _displayTime(b.actualArrivalTime, null),
          ),
          _kv(
            BookingStrings.exit,
            _displayTime(b.actualExitTime, null),
          ),
          SizedBox(height: 20.h),
          if (b.canCheckIn)
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () => _confirmAndSubmit(checkIn: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primary,
                minimumSize: Size.fromHeight(48.h),
              ),
              child: Text(BookingStrings.checkIn),
            ),
          if (b.canCheckOut) ...[
            SizedBox(height: 10.h),
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () => _confirmAndSubmit(checkIn: false),
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

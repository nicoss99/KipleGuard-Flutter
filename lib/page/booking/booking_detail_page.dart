import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api_error_message.dart';
import '../../core/offline/offline_messages.dart';
import '../../core/cache/guard_detail_cache.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/connectivity/network_connectivity.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/network/dio_network.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/app_success_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/offline_cache_banner.dart';
import '../../widget/standard_primary_header.dart';
import 'booking_guard_models.dart';
import 'booking_repository.dart';
import 'booking_strings.dart';
import 'guard_booking_repository.dart';
import 'widget/booking_action_confirm_dialog.dart';
import 'widget/booking_detail_scroll.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  const BookingDetailPage({super.key, required this.bookingUuid});

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
  bool _fromCache = false;
  DateTime? _cacheSavedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _applyCached(String residenceId) async {
    final cached = await GuardDetailCache.readBookingDetail(
      residenceUuid: residenceId,
      bookingId: widget.bookingId,
    );
    if (cached == null) return;
    setState(() {
      _booking = cached.row;
      _loading = false;
      _fromCache = true;
      _cacheSavedAt = cached.savedAt;
      _error = null;
    });
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
      _fromCache = false;
      _cacheSavedAt = null;
    });
    final snap = await DashboardPrefs.loadSnapshot();
    if (snap.residenceId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No residence selected';
      });
      return;
    }

    final online = await ref.read(connectivityServiceProvider).checkOnline();
    if (!online) {
      await _applyCached(snap.residenceId);
      setState(() {
        _loading = false;
        if (_booking == null) _error = offlineNoCachedDataMessage();
      });
      return;
    }

    try {
      final row = await ref.read(bookingRepositoryProvider).fetchBookingDetail(
            residenceUuid: snap.residenceId,
            bookingId: widget.bookingId,
          );
      await GuardDetailCache.saveBookingDetail(
        residenceUuid: snap.residenceId,
        bookingId: widget.bookingId,
        bookingJson: row.toJson(),
      );
      setState(() {
        _booking = row;
        _loading = false;
        _fromCache = false;
        _cacheSavedAt = null;
      });
    } on DioException catch (e) {
      if (isNetworkError(e)) {
        await _applyCached(snap.residenceId);
        if (_booking != null) return;
      }
      setState(() {
        _loading = false;
        _error = userFacingErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = userFacingErrorMessage(e);
      });
    }
  }

  Future<void> _confirmAndSubmit({required bool checkIn}) async {
    final ok = await showBookingActionConfirmDialog(context, checkIn: checkIn);
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
      await GuardDetailCache.saveBookingDetail(
        residenceUuid: snap.residenceId,
        bookingId: widget.bookingId,
        bookingJson: row.toJson(),
      );
      if (!mounted) return;
      setState(() {
        _booking = row;
        _fromCache = false;
        _cacheSavedAt = null;
      });
      await showAppSuccessDialog(
        context,
        message: checkIn ? BookingStrings.checkInSuccess : BookingStrings.checkOutSuccess,
      );
    } catch (e) {
      if (mounted) await showApiFailedDialog(context, error: e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget? _checkInBar(GuardBookingRow b) {
    if (!b.canCheckIn) return null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 8.h, AppSpacing.md, 12.h),
        child: FilledButton(
          onPressed: _submitting ? null : () => _confirmAndSubmit(checkIn: true),
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(52.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            backgroundColor: AppColor.primary,
            padding: EdgeInsets.symmetric(vertical: 20.h),
          ),
          child: Text(
            BookingStrings.checkIn,
            style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    listenConnectivityRefresh(ref, _load);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: _submitting,
        child: _scaffoldForState(),
      ),
    );
  }

  Widget _scaffoldForState() {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardPrimaryHeader(
              title: BookingStrings.detailsTitle,
              onBack: () => context.pop(),
            ),
            const Expanded(child: Center(child: AppProgressIndicator())),
          ],
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardPrimaryHeader(
              title: BookingStrings.detailsTitle,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.body,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final b = _booking;
    if (b == null) {
      final offline = ref.watch(isOnlineProvider).value == false;
      return Scaffold(
        backgroundColor: AppColor.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StandardPrimaryHeader(
              title: BookingStrings.detailsTitle,
              onBack: () => context.pop(),
            ),
            if (offline) const OfflineCacheBanner(fromCache: false),
            Expanded(
              child: Center(
                child: Text(
                  offline ? offlineNoCachedDataMessage() : 'Booking not found',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.body,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.white,
      bottomNavigationBar: _checkInBar(b),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StandardPrimaryHeader(
            title: BookingStrings.detailsTitle,
            onBack: () => context.pop(),
          ),
          OfflineCacheBanner(fromCache: _fromCache, savedAt: _cacheSavedAt),
          Expanded(
            child: BookingDetailScroll(
              booking: b,
              submitting: _submitting,
              onCheckOut: () => _confirmAndSubmit(checkIn: false),
              onRefresh: _load,
            ),
          ),
        ],
      ),
    );
  }
}

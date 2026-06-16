import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_error_message.dart';
import '../../core/connectivity/network_connectivity.dart';
import '../../core/offline/offline_messages.dart';
import '../../core/app_flavor.dart';
import '../../core/app_logger.dart';
import '../../core/connectivity/connectivity_refresh.dart';
import '../../core/dashboard_prefs.dart';
import '../../core/guard_api_time_display.dart';
import '../../core/guard_time_format.dart';
import '../../widget/offline_cache_banner.dart';
import '../../theme/app_color.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_style.dart';
import '../../widget/app_progress_indicator.dart';
import '../../widget/api_failed_dialog.dart';
import '../../widget/app_success_dialog.dart';
import '../../widget/modal_progress_hud.dart';
import '../../widget/standard_primary_header.dart';
import 'visitor_detail_fields.dart';
import 'visitor_detail_provider.dart';
import 'visitor_epass_share_text.dart';
import '../auth/guard_visitor_repository.dart';
import 'visitor_strings.dart';
import 'widget/visitor_details_qr_header.dart';
import 'widget/visitor_epass_actions_sheet.dart';

class VisitorDetailsPage extends ConsumerStatefulWidget {
  const VisitorDetailsPage({super.key, required this.visitorUuid});

  final String visitorUuid;

  @override
  ConsumerState<VisitorDetailsPage> createState() => _VisitorDetailsPageState();
}

class _VisitorDetailsPageState extends ConsumerState<VisitorDetailsPage> {
  var _busy = false;
  DashboardSnapshot? _dash;

  @override
  void initState() {
    super.initState();
    DashboardPrefs.loadSnapshot().then((s) {
      if (mounted) setState(() => _dash = s);
    });
  }

  /// `true` when the action was check-out; `false` for check-in.
  Future<bool> _performCheckAction(VisitorDetailFields meta) async {
    final snap = _dash ?? await DashboardPrefs.loadSnapshot();
    final residenceUuid =
        snap.residenceId.isNotEmpty ? snap.residenceId : meta.residenceUuid;
    if (residenceUuid.isEmpty) {
      if (mounted) {
        await showApiFailedDialog(
          context,
          message: 'No residence selected',
        );
      }
      return false;
    }

    final visitorId = int.tryParse(widget.visitorUuid);
    if (visitorId == null) throw StateError('Invalid visitor');

    final guardRepo = ref.read(guardVisitorRepositoryProvider);
    final isCheckOut = meta.showCheckOutButton || meta.canCheckOut;
    if (isCheckOut) {
      await guardRepo.checkOut(
        residenceUuid: residenceUuid,
        visitorId: visitorId,
      );
    } else {
      await guardRepo.checkIn(
        residenceUuid: residenceUuid,
        visitorId: visitorId,
      );
    }
    ref.invalidate(visitorDetailProvider(widget.visitorUuid));
    return isCheckOut;
  }

  Future<void> _showCheckActionSuccess(bool wasCheckOut) async {
    if (!mounted) return;
    await showAppSuccessDialog(
      context,
      message: wasCheckOut
          ? VisitorStrings.checkOutSuccess
          : VisitorStrings.checkInSuccess,
    );
  }

  Future<void> _runQr(VisitorDetailFields meta) async {
    setState(() => _busy = true);
    try {
      final wasCheckOut = await _performCheckAction(meta);
      await _showCheckActionSuccess(wasCheckOut);
    } catch (e, st) {
      AppLog.error(
        'Visitor QR failed',
        tag: 'Visitor',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        await showApiFailedDialog(context, error: e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkIn(VisitorDetailFields meta) async {
    setState(() => _busy = true);
    try {
      final wasCheckOut = await _performCheckAction(meta);
      await _showCheckActionSuccess(wasCheckOut);
    } catch (e, st) {
      AppLog.error(
        'Visitor check-in failed',
        tag: 'Visitor',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        await showApiFailedDialog(context, error: e);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(visitorDetailProvider(widget.visitorUuid));
    final strictBuilding = _dash?.isStrictBuildingOffice ?? false;

    listenConnectivityRefresh(ref, () {
      ref.invalidate(visitorDetailProvider(widget.visitorUuid));
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: standardPrimaryOverlayStyle(),
      child: ModalProgressHud(
        inAsyncCall: _busy,
        child: async.when(
          loading: () => Scaffold(
            backgroundColor: AppColor.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StandardPrimaryHeader(
                  title: VisitorStrings.detailsTitle,
                  onBack: () => context.pop(),
                ),
                const Expanded(
                  child: Center(
                    child: AppProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
          error: (e, _) => Scaffold(
            backgroundColor: AppColor.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StandardPrimaryHeader(
                  title: VisitorStrings.detailsTitle,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      userFacingErrorMessage(e),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (snap) {
            if (snap == null) {
              final offline = ref.watch(isOnlineProvider).value == false;
              return Scaffold(
                backgroundColor: AppColor.white,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StandardPrimaryHeader(
                      title: VisitorStrings.detailsTitle,
                      onBack: () => context.pop(),
                    ),
                    if (offline)
                      OfflineCacheBanner(fromCache: false),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            offline
                                ? offlineNoCachedDataMessage()
                                : 'Visitor not found',
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
            final f = snap.fields;
            return Scaffold(
              backgroundColor: AppColor.white,
              bottomNavigationBar: _checkInBar(f),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StandardPrimaryHeader(
                    title: VisitorStrings.detailsTitle,
                    onBack: () => context.pop(),
                  ),
                  OfflineCacheBanner(
                    fromCache: snap.fromCache,
                    savedAt: snap.cacheSavedAt,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          VisitorDetailsQrHeader(qrPayload: f.qrCode),
                          _sectionHeading('Visitor details'),
                          _detailRowPrimary(
                            'Name',
                            f.name.trim().isEmpty ? 'N/A' : f.name.trim(),
                          ),
                          _detailRowMuted(
                            'Unit',
                            _na(
                              f.unitDisplay(
                                strictBuildingOffice: strictBuilding,
                              ),
                            ),
                          ),
                          _detailRowMuted('Host', _na(f.hostName)),
                          _detailRowMuted('Category', _na(f.category)),
                          _detailRowMuted('Remarks', _na(f.remarks)),
                          SizedBox(height: 20.h),
                          _sectionHeading('Additional details'),
                          _detailRow(
                            label: 'IC/Passport',
                            value: f.maskedIcPassport,
                            labelMuted: false,
                            valueMuted: true,
                          ),
                          _detailRowPrimary('Car plate', _na(f.carPlate)),
                          _phoneRow(f.phone),
                          _detailRowPrimary(
                            'Pass reference ID',
                            _na(f.passReference),
                          ),
                          _detailRowPrimary('Parking lot', _na(f.parkingLot)),
                          _detailRowPrimary('Temperature', _na(f.temperature)),
                          SizedBox(height: 20.h),
                          _sectionHeading('Visit time'),
                          _detailRowMuted(
                            'ETA Arrival',
                            _fmtDateTime(f.startTime),
                          ),
                          _detailRowMuted('ETA Exit', _fmtDateTime(f.endTime)),
                          _detailRowMuted(
                            'Actual Arrival Time',
                            _fmtDateTime(f.actualArrivalTime),
                          ),
                          _detailRowMuted(
                            'Actual Exit Time',
                            _fmtDateTime(f.actualExitTime),
                          ),
                          _detailRowMuted(
                            'Submitted date',
                            _fmtDate(f.createdAt),
                          ),
                          if (f.showShareEpassButton)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                40.h,
                                20.w,
                                f.showCheckOutButton ? 12.h : 24.h,
                              ),
                              child: OutlinedButton(
                                onPressed: () => _openShareActionSheet(f),
                                style: _epassOutlinedStyle(),
                                child: Text(
                                  'Share e-Pass',
                                  style: AppTextStyle.subtitle.copyWith(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          if (f.showCheckOutButton)
                            Padding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                              child: FilledButton(
                                onPressed: () => _runQr(f),
                                style: _primaryFilledButtonStyle(),
                                child: Text(
                                  VisitorStrings.checkOut,
                                  style: AppTextStyle.subtitle.copyWith(
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ButtonStyle _epassOutlinedStyle() => OutlinedButton.styleFrom(
    side: const BorderSide(color: AppColor.primary, width: 1.5),
    foregroundColor: AppColor.primary,
    padding: EdgeInsets.symmetric(vertical: 20.h),
    minimumSize: Size.fromHeight(52.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  );

  ButtonStyle _primaryFilledButtonStyle() => FilledButton.styleFrom(
    minimumSize: Size.fromHeight(52.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    backgroundColor: AppColor.primary,
    padding: EdgeInsets.symmetric(vertical: 20.h),
  );

  /// Check-in: primary bar. Check-out: same action sheet, filled button in body under Share e-Pass.
  Widget? _checkInBar(VisitorDetailFields f) {
    if (!f.showCheckInButton) return null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.md, 8.h, AppSpacing.md, 12.h),
        child: FilledButton(
          onPressed: () => _checkIn(f),
          style: _primaryFilledButtonStyle(),
          child: Text(
            VisitorStrings.checkIn,
            style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 8.h, 15.w, 0),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyle.body.copyWith(
          color: AppColor.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailRowPrimary(String label, String value) {
    return _detailRow(
      label: label,
      value: value,
      labelMuted: false,
      valueMuted: false,
    );
  }

  Widget _detailRowMuted(String label, String value) {
    return _detailRow(
      label: label,
      value: value,
      labelMuted: true,
      valueMuted: true,
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required bool labelMuted,
    required bool valueMuted,
  }) {
    final labelStyle = AppTextStyle.body.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: labelMuted ? AppColor.textSecondary : AppColor.textPrimary,
    );
    final valueStyle = AppTextStyle.body.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: valueMuted ? AppColor.textSecondary : AppColor.textPrimary,
    );
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: labelStyle)),
              Expanded(
                child: Text(
                  value,
                  style: valueStyle,
                  textAlign: TextAlign.end,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColor.greyBorder),
      ],
    );
  }

  Widget _phoneRow(String rawPhone) {
    final value = _na(rawPhone);
    final canDial = rawPhone.trim().isNotEmpty;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Mobile number',
                  style: AppTextStyle.body.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: 36.w,
                          height: 40.h,
                        ),
                        onPressed: canDial ? () => _dial(rawPhone) : null,
                        icon: Icon(
                          Icons.phone_in_talk_rounded,
                          size: 22.sp,
                          color: AppColor.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          value,
                          style: AppTextStyle.body.copyWith(
                            fontSize: 14.sp,
                            color: AppColor.textPrimary,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColor.greyBorder),
      ],
    );
  }

  Future<void> _dial(String raw) async {
    var n = raw.trim().replaceAll(' ', '');
    if (n.isEmpty) return;
    if (!n.startsWith('0') && !n.startsWith('+')) n = '+$n';
    final uri = Uri.parse('tel:$n');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      AppLog.error('Dial failed', tag: 'Visitor', error: e, stackTrace: st);
    }
  }

  String _residenceDisplayName(VisitorDetailFields f) {
    final fromApi = f.residenceName.trim();
    if (fromApi.isNotEmpty) return fromApi;
    return (_dash?.residenceName ?? '').trim();
  }

  Future<void> _openShareActionSheet(VisitorDetailFields f) async {
    final flavor = ref.read(appFlavorProvider);
    await showVisitorEpassActionsSheet(
      context,
      onViewQr: () {
        final q = f.qrCode.trim();
        if (q.isEmpty) {
          showApiFailedDialog(context, message: VisitorStrings.qrRequired);
          return;
        }
        showVisitorQrPreviewDialog(context, q);
      },
      onShareText: () async {
        final qr = f.qrCode.trim();
        if (qr.isEmpty) {
          if (mounted) {
            await showApiFailedDialog(context, message: VisitorStrings.qrRequired);
          }
          return;
        }
        final message = buildEpassShareMessage(
          flavor: flavor,
          qrCode: qr,
          residenceDisplayName: _residenceDisplayName(f),
        );
        try {
          await Share.share(message);
        } catch (e, st) {
          AppLog.error(
            'Share e-Pass failed',
            tag: 'Visitor',
            error: e,
            stackTrace: st,
          );
          if (mounted) {
            await showApiFailedDialog(context, error: e);
          }
        }
      },
    );
  }

  String _na(String value) => value.trim().isEmpty ? 'N/A' : value.trim();

  String _fmtDateTime(String raw) {
    if (raw.trim().isEmpty) return 'N/A';
    if (_looksLikeApiLabel(raw)) return raw.trim();
    final formatted = GuardApiTimeDisplay.formatMedium(raw);
    return formatted.isEmpty ? raw : formatted;
  }

  String _fmtDate(String raw) {
    if (raw.trim().isEmpty) return 'N/A';
    if (_looksLikeApiLabel(raw)) return raw.trim();
    try {
      final dt = DateTime.parse(raw).toLocal();
      return GuardTimeFormat.displayDateOnly.format(dt);
    } catch (_) {
      try {
        final dt = DateFormat('yyyy-MM-dd HH:mm:ss').parseUtc(raw).toLocal();
        return GuardTimeFormat.displayDateOnly.format(dt);
      } catch (_) {
        return raw;
      }
    }
  }

  bool _looksLikeApiLabel(String raw) =>
      RegExp(r'[A-Za-z]{3}').hasMatch(raw) && raw.contains(',');
}

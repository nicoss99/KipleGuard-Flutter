import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_logger.dart';
import '../../../core/guard_api_time_display.dart';
import '../../../core/guard_time_format.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_text_style.dart';
import '../../visitor/widget/visitor_details_qr_header.dart';
import '../booking_guard_models.dart';
import '../booking_strings.dart';

class BookingDetailScroll extends StatelessWidget {
  const BookingDetailScroll({
    super.key,
    required this.booking,
    required this.submitting,
    required this.onCheckOut,
    required this.onRefresh,
  });

  final GuardBookingRow booking;
  final bool submitting;
  final VoidCallback onCheckOut;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final qr = (booking.qrCodeData?.isNotEmpty ?? false)
        ? booking.qrCodeData!
        : booking.bookingNumber;

    return RefreshIndicator(
      color: AppColor.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VisitorDetailsQrHeader(qrPayload: qr),
            _sectionHeading('Booking details'),
            _detailRowPrimary('Name', _na(booking.name)),
            _detailRowMuted('Unit', _na(booking.unitLabel)),
            _detailRowMuted('Category', _na(booking.category)),
            _detailRowPrimary('Room', _na(booking.bookingName)),
            _detailRowMuted('Duration', _na(booking.durationLabel)),
            SizedBox(height: 20.h),
            _sectionHeading('Contact'),
            _phoneRow(booking.dialPhone),
            SizedBox(height: 20.h),
            _sectionHeading('Booking time'),
            _detailRowMuted('ETA Arrival', _fmtDateTime(booking.etaArrivalLabel, null)),
            _detailRowMuted('ETA Exit', _fmtDateTime(booking.etaExitLabel, null)),
            _detailRowMuted(
              'Actual Arrival Time',
              _fmtDateTime(booking.actualArrivalLabel, booking.actualArrivalTime),
            ),
            _detailRowMuted(
              'Actual Exit Time',
              _fmtDateTime(booking.actualExitLabel, booking.actualExitTime),
            ),
            _detailRowMuted('Submitted date', _fmtDate(booking.submittedDate)),
            if (booking.attendeeCount != null)
              _detailRowMuted('Attendees', '${booking.attendeeCount}'),
            if (booking.canCheckOut)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 24.h),
                child: FilledButton(
                  onPressed: submitting ? null : onCheckOut,
                  style: _primaryFilledButtonStyle(),
                  child: Text(
                    BookingStrings.checkOut,
                    style: AppTextStyle.subtitle.copyWith(color: AppColor.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _primaryFilledButtonStyle() => FilledButton.styleFrom(
        minimumSize: Size.fromHeight(52.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: AppColor.primary,
        padding: EdgeInsets.symmetric(vertical: 20.h),
      );

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

  Widget _detailRowPrimary(String label, String value) =>
      _detailRow(label: label, value: value, labelMuted: false, valueMuted: false);

  Widget _detailRowMuted(String label, String value) =>
      _detailRow(label: label, value: value, labelMuted: true, valueMuted: true);

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
                  BookingStrings.mobile,
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
                        constraints: BoxConstraints.tightFor(width: 36.w, height: 40.h),
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
                          style: AppTextStyle.body.copyWith(fontSize: 14.sp),
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
    try {
      await launchUrl(Uri.parse('tel:$n'), mode: LaunchMode.externalApplication);
    } catch (e, st) {
      AppLog.error('Dial failed', tag: 'Booking', error: e, stackTrace: st);
    }
  }

  String _na(String value) => value.trim().isEmpty ? 'N/A' : value.trim();

  String _fmtDateTime(String? label, String? iso) {
    if (label != null && label.trim().isNotEmpty) return label.trim();
    if (iso == null || iso.trim().isEmpty) return 'N/A';
    if (_looksLikeApiLabel(iso)) return iso.trim();
    final formatted = GuardApiTimeDisplay.formatMedium(iso);
    return formatted.isEmpty ? iso : formatted;
  }

  String _fmtDate(String raw) {
    if (raw.trim().isEmpty) return 'N/A';
    if (_looksLikeApiLabel(raw)) return raw.trim();
    try {
      return GuardTimeFormat.displayDateOnly.format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  bool _looksLikeApiLabel(String raw) =>
      RegExp(r'[A-Za-z]{3}').hasMatch(raw) && raw.contains(',');
}

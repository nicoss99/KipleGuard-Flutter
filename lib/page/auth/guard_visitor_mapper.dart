import '../visitor/visitor_model.dart';
import 'guard_visitor_status.dart';

/// Maps guard visitor list JSON to [VisitorListItem].
abstract final class GuardVisitorMapper {
  static VisitorListItem mapVisitor(Map<String, dynamic> m, String residenceUuid) {
    final id = m['id'] as int? ?? 0;
    final status = (m['status'] ?? m['visit_status'] ?? '').toString().toLowerCase();
    return VisitorListItem(
      uuid: id.toString(),
      name: m['name'] as String? ?? m['visitor_name'] as String? ?? '',
      unitLabel: _unitLabel(m),
      carPlate: m['vehicle_number'] as String? ?? m['car_plate'] as String? ?? '',
      passId: m['pass_code'] as String? ??
          m['pass_id'] as String? ??
          m['visitor_pass_id'] as String? ??
          '',
      visitStatus: status,
      latestScanType: _latestScanType(status, m),
      startTime: m['scheduled_at'] as String? ??
          m['entry_time'] as String? ??
          m['visit_start_at'] as String? ??
          m['start_time'] as String? ??
          '',
      qrCode: m['qr_code'] as String? ?? m['qr_code_data'] as String? ?? m['pass_code'] as String? ?? '',
      residenceUuid: (m['residence_uuid'] as String?)?.trim().isNotEmpty == true
          ? m['residence_uuid'] as String
          : residenceUuid,
      category: category(m, status),
    );
  }

  static String _unitLabel(Map<String, dynamic> m) {
    final unit = m['unit'];
    if (unit is Map<String, dynamic>) {
      return unit['display_label'] as String? ??
          unit['unit_number'] as String? ??
          '';
    }
    return m['unit'] as String? ?? m['unit_name'] as String? ?? '';
  }

  static String _latestScanType(String status, Map<String, dynamic> m) {
    final legacy = m['latest_scan_type'] as String? ?? '';
    if (legacy.isNotEmpty) return legacy;
    return switch (status) {
      GuardVisitorApiStatus.checkedIn => 'IN',
      GuardVisitorApiStatus.checkedOut => 'OUT',
      _ => '',
    };
  }

  static VisitorListCategory category(Map<String, dynamic> m, String status) {
    if (m['is_overtime'] == true || status.contains('overtime')) {
      return VisitorListCategory.overtime;
    }
    return switch (status) {
      GuardVisitorApiStatus.checkedIn ||
      'in' ||
      'checkin' when m['checked_in_at'] != null || m['is_checked_in'] == true =>
        VisitorListCategory.checkedIn,
      GuardVisitorApiStatus.checkedOut => VisitorListCategory.overtime,
      GuardVisitorApiStatus.pending ||
      GuardVisitorApiStatus.approved ||
      GuardVisitorApiStatus.rejected =>
        VisitorListCategory.upcoming,
      _ when m['checked_in_at'] != null || m['is_checked_in'] == true =>
        VisitorListCategory.checkedIn,
      _ => VisitorListCategory.upcoming,
    };
  }
}

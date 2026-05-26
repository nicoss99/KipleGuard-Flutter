import '../../../page/auth/guard_visitor_day_result.dart';
import '../../../page/auth/guard_visitor_repository.dart' show GuardVisitorListResult, GuardVisitorScanResult;
import '../../../page/visitor/visitor_model.dart';

/// Guard visitor list, detail, scan, check-in/out API.
abstract interface class GuardVisitorRepository {
  Future<({String date, GuardVisitorCounts counts, List<VisitorListItem> items})>
      fetchVisitorsForDay(
    String residenceUuid, {
    required DateTime date,
  });

  Future<Map<String, dynamic>?> fetchVisitorById(
    String residenceUuid, {
    required int visitorId,
  });

  Future<GuardVisitorListResult> fetchVisitors(
    String residenceUuid, {
    required DateTime date,
    required String status,
  });

  Future<GuardVisitorScanResult> scanVisitor({
    required String residenceUuid,
    required String qrCodeData,
  });

  Future<void> checkIn({
    required String residenceUuid,
    required int visitorId,
  });

  Future<void> checkOut({
    required String residenceUuid,
    required int visitorId,
  });
}

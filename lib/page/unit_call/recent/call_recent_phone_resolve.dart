import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../guard_unit_call_repository.dart';
import '../unit_call_models.dart';
import 'call_recent_models.dart';

String? matchCallRecentHostPhone(List<UnitMemberLine> hosts, CallHistoryRow row) {
  final rowPhone = row.receiverPhone.trim();
  if (rowPhone.length > 5) return rowPhone;

  final profileId = row.receiverProfileUuid.trim();
  if (profileId.isNotEmpty) {
    for (final h in hosts) {
      if (h.membershipUuid == profileId && h.phone.trim().length > 5) {
        return h.phone.trim();
      }
    }
  }
  final name = row.receiverName.trim().toLowerCase();
  if (name.isNotEmpty && name != '—') {
    for (final h in hosts) {
      if (h.name.trim().toLowerCase() == name && h.phone.trim().length > 5) {
        return h.phone.trim();
      }
    }
  }
  return null;
}

Future<List<CallHistoryRow>> enrichCallHistoryWithPhones(
  Ref ref,
  String residenceUuid,
  List<CallHistoryRow> rows,
) async {
  if (residenceUuid.isEmpty || rows.isEmpty) return rows;

  final unitIds = rows.map((r) => r.unitId).where((id) => id.isNotEmpty).toSet();
  final hostsByUnit = <String, List<UnitMemberLine>>{};
  final repo = ref.read(guardUnitCallRepositoryProvider);

  await Future.wait(
    unitIds.map((unitId) async {
      try {
        hostsByUnit[unitId] = await repo.fetchHosts(residenceUuid, unitUuid: unitId);
      } catch (_) {
        hostsByUnit[unitId] = const [];
      }
    }),
  );

  return [
    for (final row in rows)
      row.copyWith(
        receiverPhone:
            matchCallRecentHostPhone(hostsByUnit[row.unitId] ?? const [], row) ??
                row.receiverPhone,
      ),
  ];
}

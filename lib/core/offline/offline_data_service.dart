import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../cache/app_cache_store.dart';
import '../cache/guard_cache_keys.dart';
import '../cache/guard_detail_cache.dart';
import '../cache/guard_list_cache.dart';
import '../dashboard_prefs.dart';
import '../../page/reporting/reporting_prefs.dart';

final offlineDataServiceProvider = Provider<OfflineDataService>(
  (ref) => const OfflineDataService(),
);

class OfflineCacheEntry {
  const OfflineCacheEntry({
    required this.label,
    required this.savedAt,
    required this.detail,
  });

  final String label;
  final DateTime savedAt;
  final String detail;
}

class OfflineDataSummary {
  const OfflineDataSummary({
    required this.residenceName,
    required this.pendingIncidents,
    required this.cacheEntries,
  });

  final String residenceName;
  final int pendingIncidents;
  final List<OfflineCacheEntry> cacheEntries;

  bool get hasPending => pendingIncidents > 0;
  bool get hasCache => cacheEntries.isNotEmpty;
}

/// Aggregates pending sync queue + on-device list caches for the offline screen.
final class OfflineDataService {
  const OfflineDataService();

  Future<OfflineDataSummary> loadSummary() async {
    final snap = await DashboardPrefs.loadSnapshot();
    final pending = (await ReportingPrefs.loadPendingQueue()).length;
    final entries = <OfflineCacheEntry>[];
    if (snap.residenceId.isNotEmpty) {
      entries.addAll(await _cacheEntriesForResidence(snap.residenceId));
    }
    entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return OfflineDataSummary(
      residenceName: snap.residenceName,
      pendingIncidents: pending,
      cacheEntries: entries,
    );
  }

  Future<List<OfflineCacheEntry>> _cacheEntriesForResidence(String residenceUuid) async {
    final today = DateTime.now();
    final out = <OfflineCacheEntry>[];
    final v = await GuardListCache.readVisitors(
      residenceUuid: residenceUuid,
      day: today,
      tabKey: 'all',
    );
    if (v != null) {
      out.add(OfflineCacheEntry(
        label: 'Visitors',
        savedAt: v.savedAt,
        detail: '${v.items.length} rows · ${DateFormat('d MMM yyyy').format(today)}',
      ));
    }
    for (final tab in ['all_bookings', 'checked_in', 'upcoming']) {
      final b = await GuardListCache.readBookings(
        residenceUuid: residenceUuid,
        day: today,
        tab: tab,
      );
      if (b != null) {
        out.add(OfflineCacheEntry(
          label: 'Bookings ($tab)',
          savedAt: b.savedAt,
          detail: '${b.result.bookings.length} rows',
        ));
      }
    }
    final a = await GuardListCache.readAttendance(
      residenceUuid: residenceUuid,
      day: today,
    );
    if (a != null) {
      out.add(OfflineCacheEntry(
        label: 'Attendance',
        savedAt: a.savedAt,
        detail: '${a.records.length} records',
      ));
    }
    final types = await AppCacheStore.read(GuardCacheKeys.incidentTypes(residenceUuid));
    if (types != null) {
      final count = types.data['items'];
      final n = count is List ? count.length : 0;
      out.add(OfflineCacheEntry(
        label: 'Incident types',
        savedAt: types.savedAt,
        detail: '$n types',
      ));
    }
    final callHistory = await AppCacheStore.read(GuardCacheKeys.callHistory(residenceUuid));
    if (callHistory != null) {
      final raw = callHistory.data['resource'];
      final n = raw is List ? raw.length : 0;
      out.add(OfflineCacheEntry(
        label: 'Call recent',
        savedAt: callHistory.savedAt,
        detail: '$n calls',
      ));
    }
    final unitCall = await AppCacheStore.read(GuardCacheKeys.unitCallDirectory(residenceUuid));
    if (unitCall != null) {
      final office = unitCall.data['officeMode'] == true;
      final blocks = unitCall.data['blocks'];
      final blockCount = blocks is List ? blocks.length : 0;
      out.add(OfflineCacheEntry(
        label: 'Unit call',
        savedAt: unitCall.savedAt,
        detail: office ? 'Office directory' : '$blockCount blocks',
      ));
    }
    final profile = await GuardDetailCache.readGuardProfile();
    if (profile != null) {
      out.add(OfflineCacheEntry(
        label: 'Profile',
        savedAt: profile.savedAt,
        detail: profile.guard.name,
      ));
    }
    return out;
  }
}

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/offline/offline_data_service.dart';

final offlineDataSummaryProvider =
    FutureProvider.autoDispose<OfflineDataSummary>((ref) async {
  return ref.read(offlineDataServiceProvider).loadSummary();
});

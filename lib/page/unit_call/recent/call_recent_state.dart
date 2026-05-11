import 'call_recent_models.dart';

class CallRecentState {
  const CallRecentState({
    this.loading = true,
    this.refreshing = false,
    this.error,
    this.rows = const [],
    this.searchQuery = '',
    this.residenceName = '',
    this.residenceUuid = '',
  });

  final bool loading;
  final bool refreshing;
  final String? error;
  final List<CallHistoryRow> rows;
  final String searchQuery;
  final String residenceName;
  final String residenceUuid;

  List<CallHistoryRow> get visibleRows {
    final q = searchQuery.trim().toUpperCase();
    if (q.isEmpty) return rows;
    return rows.where((r) => r.receiverName.toUpperCase().contains(q)).toList();
  }

  CallRecentState copyWith({
    bool? loading,
    bool? refreshing,
    String? error,
    bool clearError = false,
    List<CallHistoryRow>? rows,
    String? searchQuery,
    String? residenceName,
    String? residenceUuid,
  }) {
    return CallRecentState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
      rows: rows ?? this.rows,
      searchQuery: searchQuery ?? this.searchQuery,
      residenceName: residenceName ?? this.residenceName,
      residenceUuid: residenceUuid ?? this.residenceUuid,
    );
  }
}

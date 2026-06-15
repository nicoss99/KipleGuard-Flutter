import 'attendance_model.dart';

enum AttendanceShiftFlow { none, startShift, endShift }

class AttendanceState {
  const AttendanceState({
    this.tabIndex = 0,
    required this.selectedDay,
    this.records = const [],
    this.loading = false,
    this.error,
    this.shiftFlow = AttendanceShiftFlow.none,
    this.shiftPin,
    this.fromCache = false,
    this.cacheSavedAt,
  });

  final int tabIndex;
  final DateTime selectedDay;
  final List<AttendanceRecordRow> records;
  final bool loading;
  final String? error;
  final AttendanceShiftFlow shiftFlow;
  final String? shiftPin;
  final bool fromCache;
  final DateTime? cacheSavedAt;

  AttendanceState copyWith({
    int? tabIndex,
    DateTime? selectedDay,
    List<AttendanceRecordRow>? records,
    bool? loading,
    String? error,
    bool clearError = false,
    AttendanceShiftFlow? shiftFlow,
    String? shiftPin,
    bool clearShiftPin = false,
    bool? fromCache,
    DateTime? cacheSavedAt,
    bool clearCacheMeta = false,
  }) {
    return AttendanceState(
      tabIndex: tabIndex ?? this.tabIndex,
      selectedDay: selectedDay ?? this.selectedDay,
      records: records ?? this.records,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      shiftFlow: shiftFlow ?? this.shiftFlow,
      shiftPin: clearShiftPin ? null : (shiftPin ?? this.shiftPin),
      fromCache: clearCacheMeta ? false : (fromCache ?? this.fromCache),
      cacheSavedAt: clearCacheMeta ? null : (cacheSavedAt ?? this.cacheSavedAt),
    );
  }
}

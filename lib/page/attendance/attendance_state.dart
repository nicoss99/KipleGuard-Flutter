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
  });

  final int tabIndex;
  final DateTime selectedDay;
  final List<AttendanceRecordRow> records;
  final bool loading;
  final String? error;
  final AttendanceShiftFlow shiftFlow;

  AttendanceState copyWith({
    int? tabIndex,
    DateTime? selectedDay,
    List<AttendanceRecordRow>? records,
    bool? loading,
    String? error,
    bool clearError = false,
    AttendanceShiftFlow? shiftFlow,
  }) {
    return AttendanceState(
      tabIndex: tabIndex ?? this.tabIndex,
      selectedDay: selectedDay ?? this.selectedDay,
      records: records ?? this.records,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      shiftFlow: shiftFlow ?? this.shiftFlow,
    );
  }
}

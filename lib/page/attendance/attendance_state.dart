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
    this.guardUuid = '',
    this.companyUuid = '',
  });

  final int tabIndex;
  final DateTime selectedDay;
  final List<AttendanceRecordRow> records;
  final bool loading;
  final String? error;
  final AttendanceShiftFlow shiftFlow;
  final String guardUuid;
  final String companyUuid;

  AttendanceState copyWith({
    int? tabIndex,
    DateTime? selectedDay,
    List<AttendanceRecordRow>? records,
    bool? loading,
    String? error,
    bool clearError = false,
    AttendanceShiftFlow? shiftFlow,
    String? guardUuid,
    String? companyUuid,
  }) {
    return AttendanceState(
      tabIndex: tabIndex ?? this.tabIndex,
      selectedDay: selectedDay ?? this.selectedDay,
      records: records ?? this.records,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      shiftFlow: shiftFlow ?? this.shiftFlow,
      guardUuid: guardUuid ?? this.guardUuid,
      companyUuid: companyUuid ?? this.companyUuid,
    );
  }
}

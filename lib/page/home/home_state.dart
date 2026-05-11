import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool refreshing,
    String? loadError,
    @Default(false) bool triggerNoRoleDialog,
    @Default('kipleSafe') String residenceTitle,
    @Default('') String userName,
    @Default('') String userEmail,
    @Default('') String profileInitial,
    @Default(false) bool attendanceEnabled,
    @Default(false) bool visitorEnabled,
    @Default(false) bool reportEnabled,
    @Default(false) bool bookingEnabled,
    @Default(false) bool intercomEnabled,
    @Default(false) bool qrEnabled,
  }) = _HomeState;
}

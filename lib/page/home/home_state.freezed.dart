// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 bool get refreshing; String? get loadError; bool get triggerNoRoleDialog; String get residenceTitle; String get userName; String get userEmail; String get profileInitial; bool get attendanceEnabled; bool get visitorEnabled; bool get reportEnabled; bool get bookingEnabled; bool get intercomEnabled; bool get qrEnabled;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.loadError, loadError) || other.loadError == loadError)&&(identical(other.triggerNoRoleDialog, triggerNoRoleDialog) || other.triggerNoRoleDialog == triggerNoRoleDialog)&&(identical(other.residenceTitle, residenceTitle) || other.residenceTitle == residenceTitle)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.profileInitial, profileInitial) || other.profileInitial == profileInitial)&&(identical(other.attendanceEnabled, attendanceEnabled) || other.attendanceEnabled == attendanceEnabled)&&(identical(other.visitorEnabled, visitorEnabled) || other.visitorEnabled == visitorEnabled)&&(identical(other.reportEnabled, reportEnabled) || other.reportEnabled == reportEnabled)&&(identical(other.bookingEnabled, bookingEnabled) || other.bookingEnabled == bookingEnabled)&&(identical(other.intercomEnabled, intercomEnabled) || other.intercomEnabled == intercomEnabled)&&(identical(other.qrEnabled, qrEnabled) || other.qrEnabled == qrEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,refreshing,loadError,triggerNoRoleDialog,residenceTitle,userName,userEmail,profileInitial,attendanceEnabled,visitorEnabled,reportEnabled,bookingEnabled,intercomEnabled,qrEnabled);

@override
String toString() {
  return 'HomeState(refreshing: $refreshing, loadError: $loadError, triggerNoRoleDialog: $triggerNoRoleDialog, residenceTitle: $residenceTitle, userName: $userName, userEmail: $userEmail, profileInitial: $profileInitial, attendanceEnabled: $attendanceEnabled, visitorEnabled: $visitorEnabled, reportEnabled: $reportEnabled, bookingEnabled: $bookingEnabled, intercomEnabled: $intercomEnabled, qrEnabled: $qrEnabled)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 bool refreshing, String? loadError, bool triggerNoRoleDialog, String residenceTitle, String userName, String userEmail, String profileInitial, bool attendanceEnabled, bool visitorEnabled, bool reportEnabled, bool bookingEnabled, bool intercomEnabled, bool qrEnabled
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshing = null,Object? loadError = freezed,Object? triggerNoRoleDialog = null,Object? residenceTitle = null,Object? userName = null,Object? userEmail = null,Object? profileInitial = null,Object? attendanceEnabled = null,Object? visitorEnabled = null,Object? reportEnabled = null,Object? bookingEnabled = null,Object? intercomEnabled = null,Object? qrEnabled = null,}) {
  return _then(_self.copyWith(
refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as String?,triggerNoRoleDialog: null == triggerNoRoleDialog ? _self.triggerNoRoleDialog : triggerNoRoleDialog // ignore: cast_nullable_to_non_nullable
as bool,residenceTitle: null == residenceTitle ? _self.residenceTitle : residenceTitle // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,profileInitial: null == profileInitial ? _self.profileInitial : profileInitial // ignore: cast_nullable_to_non_nullable
as String,attendanceEnabled: null == attendanceEnabled ? _self.attendanceEnabled : attendanceEnabled // ignore: cast_nullable_to_non_nullable
as bool,visitorEnabled: null == visitorEnabled ? _self.visitorEnabled : visitorEnabled // ignore: cast_nullable_to_non_nullable
as bool,reportEnabled: null == reportEnabled ? _self.reportEnabled : reportEnabled // ignore: cast_nullable_to_non_nullable
as bool,bookingEnabled: null == bookingEnabled ? _self.bookingEnabled : bookingEnabled // ignore: cast_nullable_to_non_nullable
as bool,intercomEnabled: null == intercomEnabled ? _self.intercomEnabled : intercomEnabled // ignore: cast_nullable_to_non_nullable
as bool,qrEnabled: null == qrEnabled ? _self.qrEnabled : qrEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool refreshing,  String? loadError,  bool triggerNoRoleDialog,  String residenceTitle,  String userName,  String userEmail,  String profileInitial,  bool attendanceEnabled,  bool visitorEnabled,  bool reportEnabled,  bool bookingEnabled,  bool intercomEnabled,  bool qrEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.refreshing,_that.loadError,_that.triggerNoRoleDialog,_that.residenceTitle,_that.userName,_that.userEmail,_that.profileInitial,_that.attendanceEnabled,_that.visitorEnabled,_that.reportEnabled,_that.bookingEnabled,_that.intercomEnabled,_that.qrEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool refreshing,  String? loadError,  bool triggerNoRoleDialog,  String residenceTitle,  String userName,  String userEmail,  String profileInitial,  bool attendanceEnabled,  bool visitorEnabled,  bool reportEnabled,  bool bookingEnabled,  bool intercomEnabled,  bool qrEnabled)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.refreshing,_that.loadError,_that.triggerNoRoleDialog,_that.residenceTitle,_that.userName,_that.userEmail,_that.profileInitial,_that.attendanceEnabled,_that.visitorEnabled,_that.reportEnabled,_that.bookingEnabled,_that.intercomEnabled,_that.qrEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool refreshing,  String? loadError,  bool triggerNoRoleDialog,  String residenceTitle,  String userName,  String userEmail,  String profileInitial,  bool attendanceEnabled,  bool visitorEnabled,  bool reportEnabled,  bool bookingEnabled,  bool intercomEnabled,  bool qrEnabled)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.refreshing,_that.loadError,_that.triggerNoRoleDialog,_that.residenceTitle,_that.userName,_that.userEmail,_that.profileInitial,_that.attendanceEnabled,_that.visitorEnabled,_that.reportEnabled,_that.bookingEnabled,_that.intercomEnabled,_that.qrEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.refreshing = false, this.loadError, this.triggerNoRoleDialog = false, this.residenceTitle = 'kipleSafe', this.userName = '', this.userEmail = '', this.profileInitial = '', this.attendanceEnabled = false, this.visitorEnabled = false, this.reportEnabled = false, this.bookingEnabled = false, this.intercomEnabled = false, this.qrEnabled = false});
  

@override@JsonKey() final  bool refreshing;
@override final  String? loadError;
@override@JsonKey() final  bool triggerNoRoleDialog;
@override@JsonKey() final  String residenceTitle;
@override@JsonKey() final  String userName;
@override@JsonKey() final  String userEmail;
@override@JsonKey() final  String profileInitial;
@override@JsonKey() final  bool attendanceEnabled;
@override@JsonKey() final  bool visitorEnabled;
@override@JsonKey() final  bool reportEnabled;
@override@JsonKey() final  bool bookingEnabled;
@override@JsonKey() final  bool intercomEnabled;
@override@JsonKey() final  bool qrEnabled;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.refreshing, refreshing) || other.refreshing == refreshing)&&(identical(other.loadError, loadError) || other.loadError == loadError)&&(identical(other.triggerNoRoleDialog, triggerNoRoleDialog) || other.triggerNoRoleDialog == triggerNoRoleDialog)&&(identical(other.residenceTitle, residenceTitle) || other.residenceTitle == residenceTitle)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.profileInitial, profileInitial) || other.profileInitial == profileInitial)&&(identical(other.attendanceEnabled, attendanceEnabled) || other.attendanceEnabled == attendanceEnabled)&&(identical(other.visitorEnabled, visitorEnabled) || other.visitorEnabled == visitorEnabled)&&(identical(other.reportEnabled, reportEnabled) || other.reportEnabled == reportEnabled)&&(identical(other.bookingEnabled, bookingEnabled) || other.bookingEnabled == bookingEnabled)&&(identical(other.intercomEnabled, intercomEnabled) || other.intercomEnabled == intercomEnabled)&&(identical(other.qrEnabled, qrEnabled) || other.qrEnabled == qrEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,refreshing,loadError,triggerNoRoleDialog,residenceTitle,userName,userEmail,profileInitial,attendanceEnabled,visitorEnabled,reportEnabled,bookingEnabled,intercomEnabled,qrEnabled);

@override
String toString() {
  return 'HomeState(refreshing: $refreshing, loadError: $loadError, triggerNoRoleDialog: $triggerNoRoleDialog, residenceTitle: $residenceTitle, userName: $userName, userEmail: $userEmail, profileInitial: $profileInitial, attendanceEnabled: $attendanceEnabled, visitorEnabled: $visitorEnabled, reportEnabled: $reportEnabled, bookingEnabled: $bookingEnabled, intercomEnabled: $intercomEnabled, qrEnabled: $qrEnabled)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 bool refreshing, String? loadError, bool triggerNoRoleDialog, String residenceTitle, String userName, String userEmail, String profileInitial, bool attendanceEnabled, bool visitorEnabled, bool reportEnabled, bool bookingEnabled, bool intercomEnabled, bool qrEnabled
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshing = null,Object? loadError = freezed,Object? triggerNoRoleDialog = null,Object? residenceTitle = null,Object? userName = null,Object? userEmail = null,Object? profileInitial = null,Object? attendanceEnabled = null,Object? visitorEnabled = null,Object? reportEnabled = null,Object? bookingEnabled = null,Object? intercomEnabled = null,Object? qrEnabled = null,}) {
  return _then(_HomeState(
refreshing: null == refreshing ? _self.refreshing : refreshing // ignore: cast_nullable_to_non_nullable
as bool,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as String?,triggerNoRoleDialog: null == triggerNoRoleDialog ? _self.triggerNoRoleDialog : triggerNoRoleDialog // ignore: cast_nullable_to_non_nullable
as bool,residenceTitle: null == residenceTitle ? _self.residenceTitle : residenceTitle // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,profileInitial: null == profileInitial ? _self.profileInitial : profileInitial // ignore: cast_nullable_to_non_nullable
as String,attendanceEnabled: null == attendanceEnabled ? _self.attendanceEnabled : attendanceEnabled // ignore: cast_nullable_to_non_nullable
as bool,visitorEnabled: null == visitorEnabled ? _self.visitorEnabled : visitorEnabled // ignore: cast_nullable_to_non_nullable
as bool,reportEnabled: null == reportEnabled ? _self.reportEnabled : reportEnabled // ignore: cast_nullable_to_non_nullable
as bool,bookingEnabled: null == bookingEnabled ? _self.bookingEnabled : bookingEnabled // ignore: cast_nullable_to_non_nullable
as bool,intercomEnabled: null == intercomEnabled ? _self.intercomEnabled : intercomEnabled // ignore: cast_nullable_to_non_nullable
as bool,qrEnabled: null == qrEnabled ? _self.qrEnabled : qrEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

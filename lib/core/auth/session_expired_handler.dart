import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_route.dart';
import '../../router/root_navigator_key.dart';
import '../auth_prefs.dart';
import '../site_scope_invalidation.dart';
import '../../page/attendance/attendance_provider.dart';
import '../../page/booking/booking_provider.dart';
import '../../page/home/home_provider.dart';
import '../../page/login/login_provider.dart';
import '../../page/profile/profile_provider.dart';
import '../../page/visitor/visitor_provider.dart';
import '../../widget/app_confirm_dialog.dart';
import '../../theme/app_color.dart';

const sessionExpiredTitle = 'Session expired';
const sessionExpiredMessage = 'Please sign in again.';

bool sessionExpiredFlowInProgress = false;
bool _sessionExpiredDialogVisible = false;

/// True while the session-expired dialog is on screen.
bool get sessionExpiredDialogVisible => _sessionExpiredDialogVisible;

const _sessionSupersededCode = 'SESSION_SUPERSEDED';

/// Server message when the session was invalidated because the account signed in elsewhere.
const sessionSignedOutAnotherDeviceMessage =
    'This session was signed out because the account logged in on another device.';

/// True when API body uses error code `SESSION_SUPERSEDED` (another device signed in).
bool isSessionSupersededPayload(dynamic data) {
  if (data == null) return false;
  if (data is String) {
    return data.toUpperCase().contains(_sessionSupersededCode);
  }
  if (data is! Map) return false;
  final map = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);
  for (final key in ['code', 'error', 'error_code', 'errorCode', 'or_code']) {
    final v = map[key]?.toString().trim().toUpperCase();
    if (v == _sessionSupersededCode) return true;
  }
  final message = map['message']?.toString().toUpperCase() ?? '';
  return message.contains(_sessionSupersededCode);
}

/// True when [error] is a forced session end — only the session-expired dialog should show.
bool isSessionTerminationApiError(Object? error) {
  if (error is! DioException) return false;
  if (isSessionSupersededPayload(error.response?.data)) return true;
  final path = error.requestOptions.uri.path;
  if (_isPublicGuardAuthPath(path)) return false;
  if (error.response?.statusCode == 401) return true;
  if (error.type == DioExceptionType.cancel &&
      error.message?.trim().toLowerCase() == sessionExpiredTitle.toLowerCase()) {
    return true;
  }
  return false;
}

/// True when a user-facing error string is from session expiry (suppress generic dialogs).
bool isSessionExpiredUserMessage(String? message) {
  if (message == null) return false;
  final m = message.trim();
  if (m.isEmpty) return false;
  final lower = m.toLowerCase();
  if (lower == sessionExpiredTitle.toLowerCase()) return true;
  if (lower == sessionExpiredMessage.toLowerCase()) return true;
  if (m == sessionSignedOutAnotherDeviceMessage.trim()) return true;
  if (lower.contains('logged in on another device')) return true;
  if (lower.contains('session superseded')) return true;
  return false;
}

bool isSessionSupersededError(DioException error) =>
    isSessionSupersededPayload(error.response?.data);

bool _isPublicGuardAuthPath(String path) {
  const publicPaths = <String>[
    'api/v1/guard/auth/login',
    'api/v1/guard/auth/logout',
  ];
  for (final p in publicPaths) {
    if (path.contains(p)) return true;
  }
  return false;
}

bool requiresGuardAuth(String path) =>
    path.contains('api/v1/guard/') && !_isPublicGuardAuthPath(path);

void invalidateSessionAfterLogout(Ref ref) {
  ref.invalidate(homeProvider);
  ref.invalidate(loginNotifierProvider);
  ref.invalidate(profileProvider);
  ref.invalidate(visitorProvider);
  ref.invalidate(attendanceProvider);
  ref.invalidate(bookingListProvider);
  invalidateSiteScopedProviders(ref);
}

/// Clears session and shows session-expired dialog, then routes to login.
void triggerSessionExpiredFlow(Ref ref) {
  _startSessionExpiredFlow(ref);
}

void handleSessionSupersededResponse(Ref ref, RequestOptions request, dynamic data) {
  if (!isSessionSupersededPayload(data)) return;
  _startSessionExpiredFlow(ref, requestPath: request.uri.path);
}

/// Any HTTP 401 (except public login) shows the session-expired dialog.
void handleUnauthorizedApiResponse(Ref ref, RequestOptions request) {
  if (sessionExpiredFlowInProgress) return;
  if (_isPublicGuardAuthPath(request.uri.path)) return;
  _startSessionExpiredFlow(ref, requestPath: request.uri.path);
}

void _startSessionExpiredFlow(Ref ref, {String? requestPath}) {
  if (sessionExpiredFlowInProgress) return;
  if (requestPath != null && _isPublicGuardAuthPath(requestPath)) return;
  sessionExpiredFlowInProgress = true;
  unawaited(_runSessionExpiredFlow(ref));
}

Future<void> _runSessionExpiredFlow(Ref ref) async {
  try {
    await AuthPrefs.clearSession();
    invalidateSessionAfterLogout(ref);
  } catch (_) {
    // Still guide user to sign in.
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(showSessionExpiredDialog());
  });
}

/// Single app-wide session-expired dialog (401 / superseded session).
Future<void> showSessionExpiredDialog() async {
  if (_sessionExpiredDialogVisible) return;
  final rootCtx = rootNavigatorKey.currentContext;
  if (rootCtx == null || !rootCtx.mounted) {
    sessionExpiredFlowInProgress = false;
    return;
  }
  _sessionExpiredDialogVisible = true;
  try {
    await showDialog<void>(
      context: rootCtx,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (dialogCtx) => AppConfirmDialog(
        icon: Icons.error_outline,
        iconColor: AppColor.errorStrong,
        iconBackgroundColor: AppColor.errorLight,
        title: sessionExpiredTitle,
        message: sessionExpiredMessage,
        showCancel: false,
        confirmText: 'OK',
        onConfirm: () {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            GoRouter.of(ctx).go(AppRoute.login.path);
          }
        },
      ),
    );
  } finally {
    _sessionExpiredDialogVisible = false;
    sessionExpiredFlowInProgress = false;
  }
}

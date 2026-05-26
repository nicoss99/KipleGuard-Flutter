import 'dart:ui' show Locale;

import 'package:dio/dio.dart';

import '../l10n/app_localizations.dart';
import '../page/login/login_repository.dart';
import '../page/profile/profile_repository.dart';
import 'network/dio_network.dart';
import 'offline/offline_messages.dart';

/// Message for dialogs, inline errors, and snackbars.
String userFacingErrorMessage(Object e) {
  if (isConnectivityFailure(e)) return offlineNoConnectionMessage();
  if (e is StateError && e.message.isNotEmpty) return e.message;
  return apiErrorMessage(e);
}

String apiErrorMessage(Object e) {
  if (e is LoginApiException) return e.message;
  if (e is ProfileApiException) return e.message;
  if (isConnectivityFailure(e)) return offlineNoConnectionMessage();
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      final serverMsg = data['message']! as String;
      if (serverMsg.isNotEmpty && !isConnectivityFailure(serverMsg)) {
        return serverMsg;
      }
    }
    return offlineNoConnectionMessage();
  }
  return lookupAppLocalizations(const Locale('en')).apiSomethingWentWrong;
}

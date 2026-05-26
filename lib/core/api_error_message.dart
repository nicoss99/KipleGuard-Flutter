import 'dart:ui' show Locale;

import 'package:dio/dio.dart';

import '../l10n/app_localizations.dart';
import '../page/login/login_repository.dart';
import '../page/profile/profile_repository.dart';

String apiErrorMessage(Object e) {
  if (e is LoginApiException) return e.message;
  if (e is ProfileApiException) return e.message;
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message']! as String;
    }
    return e.message ?? lookupAppLocalizations(const Locale('en')).apiNetworkError;
  }
  return lookupAppLocalizations(const Locale('en')).apiSomethingWentWrong;
}

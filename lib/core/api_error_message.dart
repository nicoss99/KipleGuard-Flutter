import 'package:dio/dio.dart';

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
    return e.message ?? 'Network error';
  }
  return 'Something went wrong';
}

import 'package:dio/dio.dart';

String apiErrorMessage(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message']! as String;
    }
    return e.message ?? 'Network error';
  }
  return 'Something went wrong';
}

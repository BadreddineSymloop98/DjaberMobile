import 'package:dio/dio.dart';

import '../../error/app_exception.dart';

/// Turns every `DioException` into an [AppException] before it leaves the
/// network layer, so nothing above `core/network` imports Dio.
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: toAppException(err),
      ),
    );
  }

  static AppException toAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();
      case DioExceptionType.cancel:
        return const CancelledException();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException();
      case DioExceptionType.badCertificate:
        return const NetworkException('Certificate rejected');
      case DioExceptionType.badResponse:
        return _fromResponse(err.response);
    }
  }

  static AppException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = response?.data;
    final map = body is Map<String, dynamic> ? body : null;
    final message = _messageFrom(map) ?? 'HTTP $status';

    return switch (status) {
      401 || 403 => UnauthorizedException(message),
      404 => NotFoundException(message),
      400 || 409 || 422 => ValidationException(
          message,
          statusCode: status,
          data: map,
          fieldErrors: _fieldErrorsFrom(map),
        ),
      >= 500 => ServerException(message, statusCode: status),
      _ => UnknownException(message, data: map),
    };
  }

  /// The backend is not perfectly consistent about which key carries the human
  /// message, so all the shapes it actually uses are checked.
  static String? _messageFrom(Map<String, dynamic>? map) {
    if (map == null) return null;
    for (final key in const ['message', 'error', 'msg', 'detail']) {
      final value = map[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Express-validator returns `errors: [{ path/param, msg }]`; some routes
  /// return `errors: { field: message }`. Both are flattened to one map.
  static Map<String, String> _fieldErrorsFrom(Map<String, dynamic>? map) {
    final errors = map?['errors'];
    if (errors is Map) {
      return {
        for (final entry in errors.entries)
          entry.key.toString(): entry.value.toString(),
      };
    }
    if (errors is List) {
      final result = <String, String>{};
      for (final item in errors) {
        if (item is Map) {
          final field = (item['path'] ?? item['param'] ?? item['field'])?.toString();
          final msg = (item['msg'] ?? item['message'])?.toString();
          if (field != null && msg != null) result[field] = msg;
        }
      }
      return result;
    }
    return const {};
  }
}

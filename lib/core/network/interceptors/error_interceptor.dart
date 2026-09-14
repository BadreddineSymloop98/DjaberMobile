import 'package:dio/dio.dart';

import '../../error/app_exception.dart';

/// Turns every `DioException` into an [AppException] before it leaves the
/// network layer, so nothing above `core/network` imports Dio.
///
/// This is the single place that knows the backend's error contract. It reads
/// `code`, `message`, `fields[]` and `params` (see [AppException] for the
/// shape) and picks the exception type from the status, so the layers above
/// branch on a Dart type and a `code` — never on message text.
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

    final code = map?['code'] as String?;
    final message = _messageFrom(map) ?? '';
    final fields = _fieldsFrom(map);
    final params = map?['params'] is Map
        ? Map<String, dynamic>.from(map!['params'] as Map)
        : const <String, dynamic>{};

    return switch (status) {
      400 => ValidationException(
          message,
          statusCode: 400,
          code: code,
          fields: fields,
          params: params,
          data: map,
        ),
      401 => UnauthorizedException(
          message,
          code: code,
          params: params,
          data: map,
        ),
      402 => PaymentRequiredException(
          message,
          code: code,
          params: params,
          data: map,
        ),
      403 => ForbiddenException(message, code: code, params: params, data: map),
      404 => NotFoundException(
          message,
          code: code,
          params: params,
          data: map,
        ),
      409 => ConflictException(message, code: code, params: params, data: map),
      413 => PayloadTooLargeException(
          message,
          code: code,
          params: params,
          data: map,
        ),
      // 422 keeps `fields` too: a business rule can name the line of an order
      // it objects to, and a form that has one should still mark it.
      422 => BusinessRuleException(
          message,
          code: code,
          params: params,
          data: map,
        ),
      429 => RateLimitedException(
          message,
          code: code,
          params: params,
          data: map,
        ),
      >= 500 => ServerException(
          message,
          statusCode: status,
          code: code,
          params: params,
        ),
      _ => UnknownException(message, statusCode: status, code: code, data: map),
    };
  }

  /// The contract's `message`, which is already in the merchant's language.
  ///
  /// `message` first and alone in the normal case. The fallbacks below exist
  /// only for a body that predates the contract or is malformed — and
  /// deliberately **not** the `error` key, which the contract documents as a
  /// legacy HTTP label ("Bad Request", "Conflict") and tells clients to
  /// ignore. Reading it would put jargon in front of a merchant.
  static String? _messageFrom(Map<String, dynamic>? map) {
    if (map == null) return null;
    for (final key in const ['message', 'msg', 'detail']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  /// `fields[]` from the contract, falling back to express-validator's
  /// `errors[]`, which the backend still sends alongside it for older clients.
  static List<ApiFieldError> _fieldsFrom(Map<String, dynamic>? map) {
    if (map == null) return const [];

    for (final key in const ['fields', 'errors']) {
      final raw = map[key];
      if (raw is! List) continue;
      final out = <ApiFieldError>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final parsed = ApiFieldError.fromJson(Map<String, dynamic>.from(item));
        // A nameless or wordless entry cannot be bound to an input or shown,
        // so it is dropped rather than rendered as an empty error.
        if (parsed.field.isEmpty || parsed.message.isEmpty) continue;
        out.add(parsed);
      }
      if (out.isNotEmpty) return out;
    }

    // Some routes answer `errors: { field: message }` instead of a list.
    final raw = map['errors'];
    if (raw is Map) {
      return [
        for (final e in raw.entries)
          ApiFieldError(
            field: e.key.toString(),
            message: e.value.toString(),
          ),
      ];
    }
    return const [];
  }
}

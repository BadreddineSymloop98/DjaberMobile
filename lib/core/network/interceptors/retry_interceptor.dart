import 'dart:async';

import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../utils/logger.dart';

/// Retries transport failures with a backoff.
///
/// This exists because of where the app runs, not because the backend is
/// flaky: a merchant walking between a shop and a delivery van drops packets
/// constantly, and a single failed GET showing an error screen makes the app
/// feel broken when the network recovers a second later.
///
/// Only idempotent methods are retried. A POST is never repeated — retrying
/// "send this reply to the customer" or "receive this stock" would duplicate
/// a real-world action.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const _retryCountKey = '_retry_count';
  static const _idempotent = {'GET', 'HEAD', 'OPTIONS'};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= AppConfig.maxRetries) {
      return handler.next(err);
    }

    final delay = AppConfig.retryBackoff * (1 << attempt);
    Log.d(
      'retry ${attempt + 1}/${AppConfig.maxRetries} in ${delay.inMilliseconds}ms '
      '${options.method} ${options.path}',
      tag: 'net',
    );
    await Future<void>.delayed(delay);

    options.extra[_retryCountKey] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (!_idempotent.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        true,
      // The contract's retryable set, minus 500.
      //
      // 502/503/504 mean Meta, the courier or the AI provider is down, or a
      // container is restarting — all transient. **429** is retryable by
      // definition, and the backoff below is exactly what it is asking for.
      // A 500 is excluded on purpose: the contract calls it "our fault", and
      // repeating a request the server crashed on just delays the error the
      // merchant needs to see.
      //
      // No 4xx is ever retried. The server has already reasoned about the
      // request; the answer will not change on its own.
      DioExceptionType.badResponse =>
        const [429, 502, 503, 504].contains(err.response?.statusCode),
      _ => false,
    };
  }
}

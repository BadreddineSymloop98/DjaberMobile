import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Debug-only request tracing with timing.
///
/// Bodies are truncated and `Authorization` is never printed — a log line that
/// leaks a merchant's token into a shared terminal is a real incident, and
/// screenshots of `flutter run` output get pasted into chats.
class LoggingInterceptor extends Interceptor {
  static const _tag = 'net';
  static const _maxBodyChars = 900;
  static const _stopwatchKey = '_stopwatch';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_stopwatchKey] = Stopwatch()..start();
    Log.d('→ ${options.method} ${options.uri}', tag: _tag);
    if (options.data != null) {
      Log.d('  body ${_truncate(options.data)}', tag: _tag);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    Log.d(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path} ${_elapsed(response.requestOptions)}',
      tag: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.w(
      '✕ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.path} '
      '${_elapsed(err.requestOptions)} ${_truncate(err.response?.data)}',
      tag: _tag,
    );
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final watch = options.extra[_stopwatchKey];
    if (watch is! Stopwatch) return '';
    return '(${watch.elapsedMilliseconds}ms)';
  }

  String _truncate(Object? value) {
    if (value == null) return '';
    final text = value.toString();
    return text.length <= _maxBodyChars
        ? text
        : '${text.substring(0, _maxBodyChars)}… (${text.length} chars)';
  }
}

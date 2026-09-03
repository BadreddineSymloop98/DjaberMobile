import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/app_exception.dart';
import '../error/result.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// The single HTTP entry point.
///
/// Every method returns a [Result] instead of throwing, so repositories are
/// straight-line code and view models handle exactly two cases. Dio types stop
/// here — nothing above this file imports `package:dio`.
class ApiClient {
  ApiClient({
    required SecureStorage storage,
    required Future<void> Function() onUnauthorized,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      responseType: ResponseType.json,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Let every status through to the interceptors so error bodies are
      // parsed rather than swallowed by Dio's own throw.
      validateStatus: (_) => true,
    );

    _dio.interceptors.addAll([
      AuthInterceptor(storage: storage, onUnauthorized: onUnauthorized),
      _StatusInterceptor(),
      RetryInterceptor(dio: _dio),
      const ErrorInterceptor(),
      if (AppConfig.enableNetworkLogs) LoggingInterceptor(),
    ]);
  }

  final Dio _dio;

  /// Exposed for the rare caller that needs raw Dio — a multipart upload with
  /// progress, for example. Prefer the typed methods.
  Dio get raw => _dio;

  /// Sets a header sent on every subsequent request. Used for the interface
  /// language, so backend-generated copy comes back in the merchant's own.
  void setLanguage(String code) => _dio.options.headers['Accept-Language'] = code;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic json)? parse,
    CancelToken? cancelToken,
  }) =>
      _send(
        () => _dio.get<dynamic>(path,
            queryParameters: query, cancelToken: cancelToken),
        parse,
      );

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    T Function(dynamic json)? parse,
    CancelToken? cancelToken,
  }) =>
      _send(
        () => _dio.post<dynamic>(path,
            data: body, queryParameters: query, cancelToken: cancelToken),
        parse,
      );

  Future<Result<T>> put<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? parse,
    CancelToken? cancelToken,
  }) =>
      _send(
        () => _dio.put<dynamic>(path, data: body, cancelToken: cancelToken),
        parse,
      );

  Future<Result<T>> patch<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? parse,
    CancelToken? cancelToken,
  }) =>
      _send(
        () => _dio.patch<dynamic>(path, data: body, cancelToken: cancelToken),
        parse,
      );

  Future<Result<T>> delete<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? parse,
    CancelToken? cancelToken,
  }) =>
      _send(
        () => _dio.delete<dynamic>(path, data: body, cancelToken: cancelToken),
        parse,
      );

  Future<Result<T>> _send<T>(
    Future<Response<dynamic>> Function() call,
    T Function(dynamic json)? parse,
  ) async {
    try {
      final response = await call();
      final data = response.data;
      if (parse == null) {
        // `T` is void or dynamic — the caller only cares that it succeeded.
        return Result.success(data as T);
      }
      return Result.success(parse(data));
    } on DioException catch (e) {
      final error = e.error;
      return Result.failure(
        error is AppException ? error : ErrorInterceptor.toAppException(e),
      );
    } on AppException catch (e) {
      return Result.failure(e);
    } catch (e) {
      // Almost always a parse failure: the endpoint changed shape. Worth its
      // own message so it is not mistaken for a network problem.
      return Result.failure(UnknownException('Unexpected response: $e'));
    }
  }
}

/// Restores the "throw on non-2xx" behaviour that `validateStatus` disabled,
/// so [ErrorInterceptor] and [RetryInterceptor] see a `DioException` with the
/// body attached.
class _StatusInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      return handler.next(response);
    }
    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      ),
      true,
    );
  }
}

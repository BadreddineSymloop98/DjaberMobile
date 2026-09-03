import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';

/// Attaches the bearer token, and reports a rejected one upward.
///
/// The backend issues a long-lived token with no refresh endpoint (see
/// `backend/src/routes/auth.routes.ts`), so there is nothing to refresh against
/// on a 401 — the only correct response is to end the session. [onUnauthorized]
/// is how the app layer learns it has to.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorage storage,
    required Future<void> Function() onUnauthorized,
  })  : _storage = storage,
        _onUnauthorized = onUnauthorized;

  final SecureStorage _storage;
  final Future<void> Function() _onUnauthorized;

  /// Paths that must not carry a token, so a stale one cannot poison a login.
  static const _publicPaths = <String>{
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/forgot-password',
    '/api/auth/reset-password',
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any(options.path.startsWith);
    if (!isPublic) {
      final token = await _storage.readAuthToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final isPublic = _publicPaths.any(err.requestOptions.path.startsWith);
    if ((status == 401 || status == 403) && !isPublic) {
      await _onUnauthorized();
    }
    handler.next(err);
  }
}

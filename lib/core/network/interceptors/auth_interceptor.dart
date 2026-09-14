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

    // **401 only.**
    //
    // This used to end the session on 403 as well, on the reasonable old
    // assumption that a rejected request meant a rejected token. The error
    // contract made that wrong and dangerous: 403 is now `PLAN_LIMIT_REACHED`
    // and `FORBIDDEN`, so a merchant on the Individual plan tapping "create
    // agent" a second time would have been signed out — losing their place,
    // for hitting a limit the app should simply have explained.
    //
    // 403 is a fact about what the plan allows; only 401 is a fact about the
    // token. And a 401 has nothing to refresh against — tokens last 7 days
    // and there is no refresh endpoint — so ending the session is the only
    // correct response to it.
    if (status == 401 && !isPublic) {
      await _onUnauthorized();
    }
    handler.next(err);
  }
}

import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/network/api_client.dart';
import 'package:djaber_mobile/core/storage/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which failures end a session.
///
/// This exists because the answer changed and the change is dangerous in one
/// direction. `AuthInterceptor` used to clear the session on **401 or 403**,
/// which was defensible while a 403 only ever meant "your token will not do".
/// The error contract made 403 mean `PLAN_LIMIT_REACHED` — so a merchant on
/// the Individual plan tapping "create agent" a second time was signed out
/// for hitting a limit the app should simply have explained. Nothing in the
/// suite failed while that was true, which is why it is pinned now.
///
/// Driven through the real [ApiClient] rather than by calling the interceptor
/// directly: the decision is made inside Dio's chain, and a test that reaches
/// past the chain would not have caught this.
void main() {
  late List<String> cleared;
  late ApiClient api;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-token'});
    cleared = [];
    _Canned.status = 200;
    _Canned.body = '{}';

    final dio = Dio()..httpClientAdapter = _Canned();
    api = ApiClient(
      storage: SecureStorage(),
      onUnauthorized: () async => cleared.add('cleared'),
      dio: dio,
    );
  });

  /// Only statuses the retry interceptor leaves alone, so each case is one
  /// request and the suite stays fast. 429 and 5xx are covered by
  /// `error_contract_test`'s retry assertions instead.
  Future<void> call(int status, {String path = '/api/user-stock/agents'}) async {
    _Canned.status = status;
    _Canned.body = '{"code":"X","message":"m"}';
    await api.get<dynamic>(path);
  }

  test('401 ends the session — tokens last 7 days and there is no refresh '
      'endpoint to try', () async {
    await call(401);
    expect(cleared, hasLength(1));
  });

  test('403 does NOT, because it is a plan limit and not a bad token',
      () async {
    await call(403);
    expect(
      cleared,
      isEmpty,
      reason: 'PLAN_LIMIT_REACHED must never sign a merchant out',
    );
  });

  test('nor does any other rejection', () async {
    for (final status in const [400, 402, 404, 409, 413, 422]) {
      await call(status);
    }
    expect(cleared, isEmpty);
  });

  test('a 401 from login is wrong credentials, not an expired session',
      () async {
    // Login is a public path: it carries no token, so it has none to expire.
    await call(401, path: '/api/auth/login');
    expect(cleared, isEmpty);
  });

  test('a success clears nothing', () async {
    await api.get<dynamic>('/api/user-stock/agents');
    expect(cleared, isEmpty);
  });
}

class _Canned implements HttpClientAdapter {
  static int status = 200;
  static String body = '{}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        body,
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

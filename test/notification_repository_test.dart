import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/constants/api_endpoints.dart';
import 'package:djaber_mobile/data/repositories/notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// The first mobile use of the notifications API (brief Q7).
///
/// The shape is `{ "count": 0 }` with no envelope — read from
/// `user-notifications.controller.ts:36` and confirmed against the live
/// backend on 2026-09-10, not inferred from the route name.
void main() {
  late Dio dio;
  late NotificationRepository repo;
  late List<RequestOptions> sent;

  setUp(() {
    sent = [];
    dio = Dio();
    dio.httpClientAdapter = _Canned(sent);
    repo = NotificationRepository(api: apiForTest(dio: dio));
  });

  test('reads count out of the bare envelope', () async {
    _Canned.body = '{"count":3}';
    final result = await repo.unreadCount();

    expect(result.valueOrNull, 3);
    expect(sent.single.path, Api.notificationsUnreadCount);
    expect(sent.single.method, 'GET');
  });

  test('zero is a real answer, not a missing one', () async {
    _Canned.body = '{"count":0}';
    expect((await repo.unreadCount()).valueOrNull, 0);
  });

  test('a count sent as a string still parses — Prisma has changed a '
      'scalar type under us before', () async {
    _Canned.body = '{"count":"12"}';
    expect((await repo.unreadCount()).valueOrNull, 12);
  });

  test('a missing count degrades to 0 rather than failing the request',
      () async {
    // The alternative is a parse failure, which the UI would have to render
    // as an error — over a badge.
    _Canned.body = '{}';
    expect((await repo.unreadCount()).valueOrNull, 0);
  });

  test('a 500 is a failure, and the caller decides what to show', () async {
    _Canned.status = 500;
    _Canned.body = '{"error":"Failed to fetch unread count"}';

    final result = await repo.unreadCount();
    expect(result.isFailure, isTrue);
  });
}

class _Canned implements HttpClientAdapter {
  _Canned(this.sent);

  final List<RequestOptions> sent;
  static String body = '{"count":0}';
  static int status = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options);
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/network/api_client.dart';
import 'package:djaber_mobile/core/storage/secure_storage.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// `T4 — Agent IA` and `T5 — Connecter la page`: the create call, the OAuth
/// URL rules, and the page-to-agent link.
void main() {
  late List<RequestOptions> sent;
  late Dio dio;

  /// Answers each request from [responses], in order.
  void stub(List<(int, Map<String, dynamic>)> responses) {
    dio = Dio();
    sent = [];
    var index = 0;
    dio.httpClientAdapter = _StubAdapter((options) {
      sent.add(options);
      final (status, body) = responses[index.clamp(0, responses.length - 1)];
      index++;
      return ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    FlutterSecureStorage.setMockInitialValues({'auth_token': 't'});
  }

  ApiClient api() => ApiClient(
        storage: SecureStorage(),
        onUnauthorized: () async {},
        dio: dio,
      );

  group('agent create', () {
    test('sends the three fields and the personality wire name', () async {
      stub([
        (
          201,
          {
            'agent': {
              'id': 'a-1',
              'name': 'Assistant de vente',
              'personality': 'friendly',
              'customInstructions': 'Sois bref',
              'sellAllProducts': true,
              'isActive': true,
            },
          }
        ),
      ]);

      final result = await AgentRepository(api: api()).create(
        name: '  Assistant de vente ',
        personality: AgentPersonality.friendly,
        customInstructions: ' Sois bref ',
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.personality, AgentPersonality.friendly);

      final body = sent.single.data as Map<String, dynamic>;
      expect(sent.single.path, '/api/user-stock/agents');
      expect(body['name'], 'Assistant de vente');
      // The enum's wire name, not its Dart name.
      expect(body['personality'], 'friendly');
      expect(body['customInstructions'], 'Sois bref');
      // Not sent when the tutorial has no page yet — the page is step 4.
      expect(body.containsKey('pageIds'), isFalse);
    });

    test('empty instructions are omitted', () async {
      stub([
        (201, {'agent': {'id': 'a', 'name': 'N'}}),
      ]);

      await AgentRepository(api: api()).create(
        name: 'N',
        personality: AgentPersonality.professional,
        customInstructions: '   ',
      );

      expect(
        (sent.single.data as Map<String, dynamic>).containsKey(
          'customInstructions',
        ),
        isFalse,
      );
    });

    test('a second agent is refused with the backend reason', () async {
      // One agent per user, enforced at user-agents.controller.ts:104.
      stub([
        (
          400,
          {
            'error': 'Agent limit reached',
            'message': 'You already have an agent. Edit it instead.',
          }
        ),
      ]);

      final result = await AgentRepository(api: api()).create(
        name: 'N',
        personality: AgentPersonality.professional,
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<ValidationException>());
      // `message` wins over `error` in the interceptor's key order, and it is
      // the more useful of the two here.
      expect(result.errorOrNull!.message, contains('already have an agent'));
    });

    test('personality falls back to professional on an unknown value', () {
      expect(AgentPersonality.fromName(null), AgentPersonality.professional);
      expect(AgentPersonality.fromName('nonsense'),
          AgentPersonality.professional);
      expect(AgentPersonality.fromName('technical'),
          AgentPersonality.technical);
    });

    test('setPages replaces the whole set', () async {
      stub([
        (200, {'agent': {'id': 'a-1', 'name': 'N'}}),
      ]);

      await AgentRepository(api: api())
          .setPages(agentId: 'a-1', pageIds: ['p-1', 'p-2']);

      expect(sent.single.method, 'PUT');
      expect(sent.single.path, '/api/user-stock/agents/a-1');
      expect((sent.single.data as Map<String, dynamic>)['pageIds'],
          ['p-1', 'p-2']);
    });
  });

  group('pages', () {
    test('lists connected pages and never carries a token', () async {
      stub([
        (
          200,
          {
            'pages': [
              {
                'id': 'p-1',
                'platform': 'instagram',
                'pageId': '178',
                'pageName': 'Amel Cosmétiques',
                'isActive': true,
              },
            ],
          }
        ),
      ]);

      final result = await PageRepository(api: api()).list();
      final page = result.valueOrNull!.single;

      expect(page.id, 'p-1');
      // Our row id and Meta's page id are different things; linking uses ours.
      expect(page.pageId, '178');
      expect(page.isInstagram, isTrue);
    });

    test('asks the backend for the auth URL, per platform', () async {
      stub([
        (200, {'authUrl': 'https://www.facebook.com/v18.0/dialog/oauth?x=1'}),
      ]);

      final result =
          await PageRepository(api: api()).authUrlFor(PagePlatform.facebook);

      expect(result.valueOrNull, startsWith('https://www.facebook.com/'));
      // GET, not POST — an earlier note in the brief had this the other way.
      expect(sent.single.method, 'GET');
      expect(sent.single.path, '/api/pages/connect/facebook');
    });
  });

  group('the OAuth web view rules', () {
    const reader = OAuthFlowReader();

    test('Meta dialog navigation is left alone', () {
      expect(
        reader.read('https://www.facebook.com/v18.0/dialog/oauth?client_id=1'),
        OAuthStep.keepGoing,
      );
      expect(
        reader.read('https://www.facebook.com/login.php'),
        OAuthStep.keepGoing,
      );
    });

    test('our own callback is recognised, so it can be let through', () {
      expect(
        reader.read('https://api.example.com/api/pages/callback/facebook?code=x'),
        OAuthStep.callback,
      );
      expect(
        reader.read('https://api.example.com/api/pages/callback/instagram?code=x'),
        OAuthStep.callback,
      );
    });

    test('a callback carrying a code is never the end of the flow', () {
      // The regression. The callback request is what carries the code to the
      // backend, which saves the Page while answering it. Reading it as
      // `finished` made the web view prevent it and close: the code never left
      // the phone, and nothing was ever connected.
      for (final platform in const ['facebook', 'instagram']) {
        expect(
          reader.read('https://api.example.com/api/pages/callback/$platform'
              '?code=AQB123&state=8f2c1a2b'),
          isNot(OAuthStep.finished),
          reason: 'the $platform callback must be allowed to load',
        );
      }
    });

    test('the callback is recognised whatever host it arrives on', () {
      // `redirect_uri` is built server-side from `BACKEND_URL`, which the app
      // cannot read. Matching on the app's own `API_BASE_URL` meant a callback
      // on any other host went unseen.
      for (final host in const [
        'https://api.example.com',
        'https://djaber.72-60-190-211.sslip.io',
        'https://djaberio.symloop.com',
        'http://localhost:6001',
      ]) {
        expect(
          reader.read('$host/api/pages/callback/facebook?code=x'),
          OAuthStep.callback,
          reason: 'the callback must be seen when it comes back via $host',
        );
      }
    });

    test('a path that merely resembles the callback is not one', () {
      expect(
        reader.read('https://api.example.com/api/pages/callback/facebook/extra'),
        OAuthStep.keepGoing,
      );
      expect(
        reader.read('https://www.facebook.com/api/pages/connect/facebook'),
        OAuthStep.keepGoing,
      );
    });

    test('the web-app dashboard redirect ends the flow', () {
      // With no `window.opener` the backend's callback page redirects to
      // FRONTEND_URL/dashboard?section=pages once it has done the work — a
      // desktop page the phone must never actually show.
      expect(
        reader.read('https://djaber.vercel.app/dashboard?section=pages'),
        OAuthStep.finished,
      );
    });

    test('a refusal is told apart from a success', () {
      expect(
        reader.read('https://api.example.com/api/pages/callback/facebook'
            '?error=access_denied&error_reason=user_denied'),
        OAuthStep.denied,
      );
      expect(OAuthFlowReader.isDenial('https://x.test/cb?error_code=200'), isTrue);
      expect(OAuthFlowReader.isDenial('https://x.test/cb?code=ok'), isFalse);
    });
  });

  group('reading the callback page', () {
    // Built like the examples for `GET /api/pages/callback/*` in the live
    // docs: the result sits in the script, the status is 200 either way.
    String page(String payload) =>
        '<html><body><script>(function(){var payload=$payload;'
        'if(window.opener){try{window.opener.postMessage(payload,'
        '"https://djaber.ai")}catch(e){}window.close()}else{'
        'window.location.replace("https://djaber.ai/dashboard?section=pages")'
        '}})();</script><p>Returning to Djaber…</p></body></html>';

    test('a Facebook success carries the page count', () {
      final report = OAuthFlowReader.parseCallbackPage(
        page('{"type":"facebook-oauth-success","pages":2}'),
      );
      expect(report?.succeeded, isTrue);
      expect(report?.pageCount, 2);
    });

    test('an Instagram success carries the username', () {
      final report = OAuthFlowReader.parseCallbackPage(
        page('{"type":"instagram-oauth-success","username":"boutique.sara"}'),
      );
      expect(report?.succeeded, isTrue);
      expect(report?.username, 'boutique.sara');
    });

    test('an error is a failure, whatever the status said', () {
      final report = OAuthFlowReader.parseCallbackPage(
        page('{"type":"instagram-oauth-error",'
            '"error":"Add this account as an Instagram Tester"}'),
      );
      expect(report?.succeeded, isFalse);
      expect(report?.reason, 'Add this account as an Instagram Tester');
    });

    test('a page that is not the callback page reports nothing', () {
      expect(
        OAuthFlowReader.parseCallbackPage(
          '<html><body><h1>Dashboard</h1></body></html>',
        ),
        isNull,
      );
    });

    test("Android's quoted answer and iOS's bare one read the same", () {
      final html = page('{"type":"facebook-oauth-success","pages":1}');
      expect(OAuthFlowReader.unwrapJsString(jsonEncode(html)), html);
      expect(OAuthFlowReader.unwrapJsString(html), html);
      expect(OAuthFlowReader.unwrapJsString(null), isEmpty);
    });
  });
}

/// Answers every request from a callback instead of the network.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:djaber_mobile/data/models/delivery.dart';
import 'package:djaber_mobile/data/models/order.dart';
import 'package:djaber_mobile/data/repositories/delivery_repository.dart';
import 'package:djaber_mobile/data/repositories/order_repository.dart';
import 'package:djaber_mobile/presentation/screens/delivery/delivery_fees_screen.dart';
import 'package:djaber_mobile/presentation/screens/delivery/delivery_provider_form_screen.dart';
import 'package:djaber_mobile/presentation/screens/delivery/delivery_providers_screen.dart';
import 'package:djaber_mobile/presentation/screens/delivery/delivery_screen.dart';
import 'package:djaber_mobile/presentation/screens/delivery/delivery_sheets.dart';
import 'package:djaber_mobile/presentation/viewmodels/delivery_fees_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/delivery_provider_form_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/delivery_providers_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/send_to_carrier_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// `Livraison` — the six screens, against canned answers in the live API's
/// documented shapes (Swagger, 2026-10-01), so the real repositories parse.
void main() {
  late _Backend backend;
  late DeliveryRepository delivery;
  late OrderRepository orders;

  setUp(() {
    backend = _Backend();
    final dio = Dio()..httpClientAdapter = backend;
    final api = apiForTest(dio: dio);
    delivery = DeliveryRepository(api: api);
    orders = OrderRepository(api: api);
  });

  group('what the API answers, read', () {
    test('tracking: the courier’s raw fields, one level of nesting folded', () {
      final t = ParcelTracking.fromJson({
        'success': true,
        'data': {
          'tracking': 'yal-1A2B',
          'last_status': 'En cours de livraison',
          'empty': '',
          'to': {'wilaya': 'Constantine'},
        },
      });
      expect(t, isA<ParcelFound>());
      final fields = (t as ParcelFound).fields;
      expect(fields.map((e) => e.key), ['tracking', 'last_status', 'to.wilaya']);
      expect(fields.last.value, 'Constantine');
    });

    test('tracking: the courier’s error is kept word for word', () {
      final t = ParcelTracking.fromJson({
        'success': false,
        'data': {'error': 'Tracking ID not found: yal-1A2B'},
      });
      expect((t as ParcelError).message, 'Tracking ID not found: yal-1A2B');
    });

    test('label: a link, a PDF, or a reason', () {
      expect(ShippingLabel.fromJson({'success': true, 'data': {'type': 'url', 'data': 'https://x/l.pdf'}}), isA<LabelUrl>());
      final pdf = ShippingLabel.fromJson({
        'success': true,
        'data': {'type': 'pdf', 'data': base64Encode([37, 80, 68, 70])},
      });
      expect((pdf as LabelPdf).bytes, [37, 80, 68, 70]);
      final zr = ShippingLabel.fromJson({'success': false, 'data': {'error': 'Labels not supported by ZR Express'}});
      expect((zr as LabelUnavailable).message, 'Labels not supported by ZR Express');
      final notYet = ShippingLabel.fromJson({'success': true, 'data': {'type': 'url', 'data': null}});
      expect((notYet as LabelUnavailable).message, isEmpty);
    });

    test('an order knows when it can be sent and tracked', () {
      Order o(String status, String delivery, [String? tracking]) => Order.fromJson({
            'id': 'o',
            'orderNumber': 'ORD-1',
            'clientName': 'A',
            'status': status,
            'deliveryStatus': delivery,
            'trackingNumber': tracking,
            'orderDate': '2026-10-01T10:00:00Z',
          });
      expect(o('confirmed', 'not_sent').canSendToDelivery, isTrue);
      expect(o('cancelled', 'not_sent').canSendToDelivery, isFalse);
      expect(o('returned', 'not_sent').canSendToDelivery, isFalse);
      expect(o('shipped', 'sent', 'yal-1').canSendToDelivery, isFalse);
      expect(o('shipped', 'sent', 'yal-1').canTrack, isTrue);
      expect(o('shipped', 'sent').canTrack, isFalse, reason: 'nothing to look up without a tracking number');
    });
  });

  group('what is sent', () {
    test('send: the chosen wilaya, the commune name, stop desk and the account', () async {
      await delivery.send('o-1', providerId: 'p1', toWilayaId: 31, communeName: 'Oran', isStopdesk: true, note: ' Appeler ');
      final body = backend.lastBody('POST', '/api/user-stock/delivery/send/o-1');
      expect(body, {'providerId': 'p1', 'toWilayaId': 31, 'toCommuneId': 'Oran', 'isStopdesk': true, 'note': 'Appeler'});
    });

    test('rates: the courier name, as the web sends it', () async {
      final rates = await delivery.rates(courier: 'yalidine', toWilayaId: 16);
      expect(backend.lastQuery('/api/user-stock/delivery/rates'), {'provider': 'yalidine', 'toWilaya': '16'});
      expect(rates.valueOrNull, (home: 400.0, stopdesk: 250.0));
    });

    test('an edit that leaves the credentials alone does not send them', () async {
      await delivery.updateProvider('p1', displayName: 'Yalidine', isDefault: true);
      final body = backend.lastBody('PUT', '/api/user-stock/delivery/providers/p1');
      expect(body.containsKey('credentials'), isFalse);
      expect(body['isDefault'], isTrue);
    });
  });

  group('the send sheet', () {
    test('starts from the order: its wilaya, its stop desk, the default courier', () async {
      final order = _order(wilayaId: 31, isStopdesk: true);
      final model = SendToCarrierViewModel(delivery: delivery, order: order);
      addTearDown(model.dispose);
      await model.load();
      expect(model.wilayaId, 31);
      expect(model.isStopdesk, isTrue);
      expect(model.providerId, 'p1', reason: 'the default account');
      expect(model.providers.map((p) => p.id), ['p1'], reason: 'an inactive account cannot send');
      expect(model.rates, (home: 400.0, stopdesk: 250.0));
    });

    test('no account: the empty state, not an error', () async {
      backend.providers = [];
      final model = SendToCarrierViewModel(delivery: delivery, order: _order());
      addTearDown(model.dispose);
      await model.load();
      expect(model.hasNoProvider, isTrue);
      expect(model.canSend, isFalse);
    });

    test('a courier refusal stays on the sheet', () async {
      backend.sendError = 'Wilaya non desservie';
      final model = SendToCarrierViewModel(delivery: delivery, order: _order(wilayaId: 16));
      addTearDown(model.dispose);
      await model.load();
      expect(await model.send(), isNull);
      expect(model.sendError?.message, 'Wilaya non desservie');
    });
  });

  group('the fee table', () {
    test('a changed price shows Save; saving makes the row custom', () async {
      final model = DeliveryFeesViewModel(delivery: delivery);
      addTearDown(model.dispose);
      await model.load();
      final alger = model.rows.firstWhere((r) => r.saved.wilayaId == 16);
      expect(alger.isDirty, isFalse);
      alger.home.text = '450';
      expect(alger.isDirty, isTrue);
      await model.save(alger);
      expect(alger.isDirty, isFalse);
      expect(alger.saved.isCustom, isTrue);
      expect(backend.lastBody('POST', '/api/user-stock/delivery/fees')['homePrice'], 450);
    });

    test('a reload keeps what the merchant is still typing in another row', () async {
      final model = DeliveryFeesViewModel(delivery: delivery);
      addTearDown(model.dispose);
      await model.load();
      final oran = model.rows.firstWhere((r) => r.saved.wilayaId == 31);
      oran.home.text = '999';
      await model.load();
      expect(oran.home.text, '999');
    });

    test('search finds a wilaya by French name, Arabic name or code', () async {
      final model = DeliveryFeesViewModel(delivery: delivery);
      addTearDown(model.dispose);
      await model.load();
      model.setSearch('alg');
      expect(model.rows.map((r) => r.saved.wilayaId), contains(16));
      model.setSearch('الجزائر');
      expect(model.rows.map((r) => r.saved.wilayaId), contains(16));
      model.setSearch('31');
      expect(model.rows.map((r) => r.saved.wilayaId), [31]);
    });
  });

  group('the provider form', () {
    test('add offers only the couriers without an account, and needs every credential', () async {
      final model = DeliveryProviderFormViewModel(delivery: delivery);
      addTearDown(model.dispose);
      await model.load();
      expect(model.selectableCouriers.map((c) => c.id), ['zrexpress'], reason: 'yalidine and maystro are taken');
      model.setCourier('zrexpress');
      expect(model.displayName.text, 'ZR Express', reason: 'the name follows the courier');
      model.credential('token').text = 'tok';
      expect(await model.save(), isNull, reason: 'the key is missing');
      model.credential('key').text = 'key';
      expect(await model.save(), isNotNull);
      expect(backend.lastBody('POST', '/api/user-stock/delivery/providers')['credentials'], {'token': 'tok', 'key': 'key'});
    });

    test('edit keeps the stored credentials when nothing is typed', () async {
      final model = DeliveryProviderFormViewModel(delivery: delivery, editing: _yalidine);
      addTearDown(model.dispose);
      await model.load();
      expect(model.hasChanges, isFalse);
      model.displayName.text = 'Yalidine pro';
      expect(model.hasChanges, isTrue);
      expect(await model.save(), isNotNull);
      expect(backend.lastBody('PUT', '/api/user-stock/delivery/providers/p1').containsKey('credentials'), isFalse);
    });

    test('a credentials test reports the courier’s answer', () async {
      final model = DeliveryProviderFormViewModel(delivery: delivery, editing: _yalidine);
      addTearDown(model.dispose);
      await model.load();
      expect(model.canTest, isFalse);
      model.credential('id').text = 'a';
      model.credential('token').text = 'b';
      await model.runTest();
      expect(model.test, (ok: true, message: 'Credentials are valid'));
    });
  });

  group('deleting a provider', () {
    Future<DeliveryProvidersViewModel> loaded() async {
      final model = DeliveryProvidersViewModel(delivery: delivery);
      addTearDown(model.dispose);
      await model.load();
      return model;
    }

    test('the card is busy while it runs, and a second tap is ignored', () async {
      final model = await loaded();
      final yalidine = model.providers.first;
      backend.deleteGate = Completer<void>();
      final first = model.delete(yalidine);
      await Future<void>.delayed(Duration.zero);
      expect(model.isDeleting(yalidine), isTrue);
      expect((await model.delete(yalidine)).kind, DeleteKind.ignored);
      backend.deleteGate!.complete();
      expect((await first).kind, DeleteKind.deleted);
      expect(model.isDeleting(yalidine), isFalse);
      expect(model.providers.map((p) => p.id), ['p2']);
      expect(backend.requests.where((r) => r.method == 'DELETE'), hasLength(1));
    });

    test('already deleted elsewhere (404): the card goes, said as such', () async {
      backend.deleteStatus = 404;
      final model = await loaded();
      final outcome = await model.delete(model.providers.first);
      expect(outcome.kind, DeleteKind.alreadyGone);
      expect(model.providers.map((p) => p.id), ['p2']);
    });

    test('a server error keeps the card', () async {
      backend.deleteStatus = 500;
      final model = await loaded();
      final outcome = await model.delete(model.providers.first);
      expect(outcome.kind, DeleteKind.failed);
      expect(model.providers, hasLength(2));
    });

    testWidgets('the sheet warns about sent orders, and about the default courier', (tester) async {
      final session = await sessionForTest();
      session.markBootComplete();
      addTearDown(session.dispose);
      tester.view.physicalSize = const Size(411, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(authHost(
        const DeliveryProvidersScreen(),
        session,
        extra: [Provider<DeliveryRepository>.value(value: delivery)],
      ));
      await tester.pumpAndSettle();

      // Yalidine is the default; its trash button is the first one.
      await tester.tap(find.bySemanticsLabel('Supprimer').first);
      await tester.pumpAndSettle();
      expect(find.text('Supprimer le transporteur'), findsOneWidget);
      expect(find.text('Commandes déjà envoyées'), findsOneWidget);
      expect(find.textContaining('Celles envoyées avec Yalidine'), findsOneWidget);
      expect(find.textContaining('transporteur par défaut : choisissez-en un autre'), findsOneWidget);

      // Annuler keeps it.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Annuler'));
      await tester.pumpAndSettle();
      expect(backend.requests.where((r) => r.method == 'DELETE'), isEmpty);

      // Supprimer removes it.
      await tester.tap(find.bySemanticsLabel('Supprimer').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
      await tester.pumpAndSettle();
      expect(find.text('Yalidine supprimé'), findsOneWidget);
      expect(find.text('Boutique Amel'), findsNothing);
    });
  });

  group('the screens, in each language at the narrowest handset', () {
    late SessionViewModel session;

    setUp(() async {
      session = await sessionForTest();
      session.markBootComplete();
    });

    tearDown(() => session.dispose());

    Future<void> pump(WidgetTester tester, Widget screen, AppLanguage language) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(authHost(
        screen,
        session,
        locale: language.locale,
        extra: [
          Provider<DeliveryRepository>.value(value: delivery),
          Provider<OrderRepository>.value(value: orders),
        ],
      ));
      await tester.pumpAndSettle();
    }

    for (final language in AppLanguage.values) {
      testWidgets('overview in ${language.code}', (tester) async {
        await pump(tester, const DeliveryScreen(), language);
        expect(tester.takeException(), isNull);
        expect(find.text('ORD-0001'), findsOneWidget);
      });

      testWidgets('fees in ${language.code}', (tester) async {
        await pump(tester, const DeliveryFeesScreen(), language);
        expect(tester.takeException(), isNull);
      });

      testWidgets('providers in ${language.code}', (tester) async {
        await pump(tester, const DeliveryProvidersScreen(), language);
        expect(tester.takeException(), isNull);
        expect(find.text('Yalidine'), findsWidgets);
      });

      testWidgets('provider form in ${language.code}', (tester) async {
        await pump(tester, const DeliveryProviderFormScreen(editing: _yalidine), language);
        expect(tester.takeException(), isNull);
      });

      testWidgets('send sheet in ${language.code}', (tester) async {
        await pump(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSendToCarrierSheet(context, order: _order(wilayaId: 16)),
                child: const Text('open'),
              ),
            ),
          ),
          language,
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}

const _yalidine = DeliveryProvider(
  id: 'p1',
  provider: 'yalidine',
  displayName: 'Yalidine',
  isDefault: true,
  senderName: 'Boutique Amel',
  senderPhone: '0550441230',
  senderWilayaId: 16,
);

Order _order({int? wilayaId, bool isStopdesk = false}) => Order.fromJson({
      'id': 'o-1',
      'orderNumber': 'ORD-0001',
      'clientName': 'Sara Kaci',
      'clientPhone': '0770332109',
      'clientAddress': 'Rue Didouche Mourad, Alger',
      'total': '15200.00',
      'status': 'confirmed',
      'deliveryStatus': 'not_sent',
      'wilayaId': wilayaId,
      'isStopdesk': isStopdesk,
      'orderDate': '2026-10-01T10:00:00Z',
    });

/// The delivery and order routes, answered in their documented shapes.
class _Backend implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  List<Map<String, dynamic>> providers = [
    {
      'id': 'p1',
      'provider': 'yalidine',
      'displayName': 'Yalidine',
      'isActive': true,
      'isDefault': true,
      'senderName': 'Boutique Amel',
      'senderPhone': '0550441230',
      'senderWilayaId': 16,
    },
    {'id': 'p2', 'provider': 'maystro', 'displayName': 'Maystro Delivery', 'isActive': false, 'isDefault': false},
  ];

  String? sendError;

  /// What `DELETE /delivery/providers/{id}` answers — 200, 404, 500.
  int deleteStatus = 200;

  /// Holds the DELETE open until completed, to see the busy state.
  Completer<void>? deleteGate;

  Map<String, dynamic> lastBody(String method, String path) {
    final r = requests.lastWhere((r) => r.method == method && r.path == path);
    return Map<String, dynamic>.from(r.data is String ? jsonDecode(r.data as String) : r.data as Map);
  }

  Map<String, String> lastQuery(String path) =>
      requests.lastWhere((r) => r.path == path).queryParameters.map((k, v) => MapEntry(k, '$v'));

  static const _wilayas = [
    {'id': 16, 'code': '16', 'name': 'الجزائر', 'nameFr': 'Alger', 'nameEn': 'Algiers'},
    {'id': 31, 'code': '31', 'name': 'وهران', 'nameFr': 'Oran', 'nameEn': 'Oran'},
  ];

  dynamic _answer(RequestOptions o) {
    final p = o.path.replaceFirst('/api/user-stock', '');
    final m = o.method;
    if (p == '/orders' && m == 'GET') {
      return {
        'orders': [
          _order(wilayaId: 16).toString().isEmpty ? null : {
            'id': 'o-1', 'orderNumber': 'ORD-0001', 'clientName': 'Sara Kaci', 'clientPhone': '0770332109',
            'clientAddress': 'Rue Didouche Mourad, Alger', 'total': '15200.00', 'status': 'confirmed',
            'deliveryStatus': 'not_sent', 'orderDate': '2026-10-01T10:00:00Z',
          },
          {
            'id': 'o-2', 'orderNumber': 'ORD-0002', 'clientName': 'Karim Djaballah', 'total': '5400.00',
            'status': 'shipped', 'deliveryStatus': 'in_transit', 'trackingNumber': 'yal-1A2B3C4D',
            'deliveryProvider': 'p1', 'orderDate': '2026-10-01T09:00:00Z',
          },
        ],
        'total': 2,
      };
    }
    if (p == '/orders/stats') {
      return {'stats': {'totalOrders': 2, 'notSent': 8, 'sent': 21, 'inTransit': 13, 'deliveredDelivery': 96}};
    }
    if (p == '/delivery/wilayas') return {'wilayas': _wilayas};
    if (p == '/delivery/providers' && m == 'GET') return {'providers': providers};
    if (p == '/delivery/providers' && m == 'POST') {
      return {'provider': {'id': 'p3', 'provider': 'zrexpress', 'displayName': 'ZR Express', 'isActive': true}};
    }
    if (p.startsWith('/delivery/providers/') && m == 'PUT') return {'provider': providers.first};
    if (p == '/delivery/providers/available') {
      return {
        'providers': [
          {'id': 'yalidine', 'name': 'Yalidine', 'website': 'https://yalidine.app', 'credentials': [
            {'key': 'id', 'label': 'API ID', 'type': 'text', 'required': true},
            {'key': 'token', 'label': 'API Token', 'type': 'password', 'required': true},
          ]},
          {'id': 'zrexpress', 'name': 'ZR Express', 'website': 'https://zrexpress.com', 'credentials': [
            {'key': 'token', 'label': 'Token', 'type': 'password', 'required': true},
            {'key': 'key', 'label': 'Key', 'type': 'password', 'required': true},
          ]},
          {'id': 'maystro', 'name': 'Maystro Delivery', 'website': 'https://maystro-delivery.com', 'credentials': [
            {'key': 'token', 'label': 'API Token', 'type': 'password', 'required': true},
          ]},
        ],
      };
    }
    if (p == '/delivery/providers/test') return {'success': true, 'message': 'Credentials are valid'};
    if (p == '/delivery/rates') return {'success': true, 'rates': {'home_delivery': 400, 'stopdesk': '250'}};
    if (p == '/delivery/fees' && m == 'GET') {
      return {
        'rules': [
          for (var id = 1; id <= 58; id++)
            {
              'wilayaId': id,
              'code': id.toString().padLeft(2, '0'),
              'name': id == 16 ? 'Alger' : id == 31 ? 'Oran' : 'Wilaya $id',
              'nameAr': id == 16 ? 'الجزائر' : 'ولاية $id',
              'homePrice': 600, 'stopdeskPrice': 400, 'returnPrice': 300,
              'isCustom': false, 'isActive': true,
            },
        ],
      };
    }
    if (p == '/delivery/fees' && m == 'POST') return {'rule': {'wilayaId': 16, 'homePrice': '450.00'}};
    if (p.startsWith('/delivery/send/')) {
      if (sendError != null) return (400, {'error': sendError, 'message': sendError});
      return {'order': {'id': 'o-1', 'orderNumber': 'ORD-0001', 'clientName': 'Sara Kaci', 'status': 'shipped',
        'deliveryStatus': 'sent', 'trackingNumber': 'yal-9', 'deliveryProvider': 'p1', 'orderDate': '2026-10-01T10:00:00Z'},
        'shipment': {}, 'tracking': 'yal-9'};
    }
    if (p.startsWith('/delivery/providers/') && m == 'DELETE') {
      return deleteStatus == 200
          ? {'success': true}
          : (deleteStatus, {'error': 'x', 'message': deleteStatus == 404 ? 'Not found' : 'Server error'});
    }
    return (404, {'error': 'Not found', 'message': 'Not found'});
  }

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (options.method == 'DELETE' && deleteGate != null) await deleteGate!.future;
    final answer = _answer(options);
    final (status, body) = answer is (int, Object) ? answer : (200, answer);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}


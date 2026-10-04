import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:djaber_mobile/data/models/order.dart';
import 'package:djaber_mobile/data/models/sale.dart';
import 'package:djaber_mobile/data/repositories/client_repository.dart';
import 'package:djaber_mobile/data/repositories/order_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/data/repositories/sale_repository.dart';
import 'package:djaber_mobile/presentation/screens/sales/edit_sale_screen.dart';
import 'package:djaber_mobile/presentation/screens/sales/new_sale_screen.dart';
import 'package:djaber_mobile/presentation/screens/sales/sale_detail_screen.dart';
import 'package:djaber_mobile/presentation/screens/sales/sales_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/edit_sale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/new_sale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/sale_detail_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/sales_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// `Ventes` — the five screens, against canned answers in the live API's
/// documented shapes (Swagger, 2026-10-01), so the real repositories parse.
void main() {
  late _Backend backend;
  late SaleRepository sales;
  late ProductRepository products;
  late ClientRepository clients;

  setUp(() {
    backend = _Backend();
    final dio = Dio()..httpClientAdapter = backend;
    final api = apiForTest(dio: dio);
    sales = SaleRepository(api: api);
    products = ProductRepository(api: api);
    clients = ClientRepository(api: api);
  });

  group('what the API answers, read', () {
    test('money is parsed from Decimal strings, and an unknown method is kept', () {
      final sale = Sale.fromJson({..._partial, 'paymentMethod': 'other'});
      expect(sale.total, 12900);
      expect(sale.amountPaid, 6900);
      expect(sale.remaining, 6000);
      expect(sale.paymentMethod, isNull);
      expect(sale.paymentMethodWire, 'other');
      expect(sale.itemCount, 3, reason: 'lines, not units');
    });

    test('only a sale with nothing received can be deleted', () {
      expect(Sale.fromJson(_pending).canDelete, isTrue);
      expect(Sale.fromJson(_partial).canDelete, isFalse, reason: 'the API refuses money recorded');
      expect(Sale.fromJson(_paid).canDelete, isFalse);
      expect(
        Sale.fromJson({..._pending, 'total': '0.00', 'paymentStatus': 'paid'}).canDelete,
        isFalse,
        reason: 'a zero-total sale is derived paid',
      );
    });
  });

  group('what is sent', () {
    test('list: “has remaining” wins over a status, and the end date covers its day', () async {
      await sales.list(
        paymentStatus: PaymentStatus.paid,
        hasRemaining: true,
        paymentMethod: PaymentMethod.ccp,
        endDate: DateTime(2026, 10, 1),
        offset: 30,
      );
      final q = backend.lastQuery('/api/user-stock/sales');
      expect(q['hasRemaining'], 'true');
      expect(q.containsKey('paymentStatus'), isFalse);
      expect(q['paymentMethod'], 'ccp');
      expect(q['endDate'], DateTime(2026, 10, 1, 23, 59, 59, 999).toUtc().toIso8601String());
      expect(q['offset'], '30');
    });

    test('create: an amount, never the legacy status; digits only for the phone', () async {
      final model = NewSaleViewModel(sales: sales, clients: clients, products: products);
      addTearDown(model.dispose);
      await model.load();
      model.addLine(model.sellableProducts.firstWhere((p) => p.id == 'p-parfum'));
      model.name.controller.text = ' Sara Kaci ';
      model.phone.controller.text = '0770 33 21 09';
      model.paid.controller.text = '3000';
      await model.createSale();
      final body = backend.lastBody('POST', '/api/user-stock/sales');
      expect(body['customerName'], 'Sara Kaci');
      expect(body['customerPhone'], '0770332109');
      expect(body['amountPaid'], 3000);
      expect(body.containsKey('paymentStatus'), isFalse);
      expect(body['items'], [
        {'productId': 'p-parfum', 'quantity': 1, 'unitPrice': 4200.0},
      ]);
      expect(body['saleDate'], isA<String>());
    });
  });

  group('the list', () {
    test('pages in as it scrolls, without showing an overlap twice', () async {
      backend.total = 4;
      final model = SalesViewModel(sales: sales);
      addTearDown(model.dispose);
      await model.load();
      expect(model.sales, hasLength(3));
      expect(model.hasMore, isTrue);
      backend.nextPage = [_partial, _extra];
      await model.loadMore();
      expect(model.sales.map((s) => s.id), ['s-1', 's-2', 's-3', 's-4']);
      expect(model.hasMore, isFalse);
    });

    test('the quick chips map to the API’s filters', () async {
      final model = SalesViewModel(sales: sales);
      addTearDown(model.dispose);
      await model.load();
      model.setQuick(SaleQuickFilter.remaining);
      await pumpEventQueue();
      expect(backend.lastQuery('/api/user-stock/sales')['hasRemaining'], 'true');
      expect(model.isQuickSelected(SaleQuickFilter.remaining), isTrue);
      model.setQuick(SaleQuickFilter.paid);
      await pumpEventQueue();
      expect(backend.lastQuery('/api/user-stock/sales')['paymentStatus'], 'paid');
      expect(model.filters.activeCount, 1);
    });

    test('a sale deleted elsewhere leaves the list; a refusal keeps it', () async {
      final model = SalesViewModel(sales: sales);
      addTearDown(model.dispose);
      await model.load();
      final pending = model.sales.firstWhere((s) => s.id == 's-3');
      backend.deleteStatus = 400;
      expect((await model.delete(pending)).isFailure, isTrue);
      expect(model.sales, hasLength(3));
      backend.deleteStatus = 404;
      await model.delete(pending);
      expect(model.sales.map((s) => s.id), ['s-1', 's-2']);
    });

    testWidgets('the trash is only on the unpaid sale, and asks first', (tester) async {
      final session = await sessionForTest();
      session.markBootComplete();
      addTearDown(session.dispose);
      tester.view.physicalSize = const Size(411, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(authHost(
        const SalesScreen(),
        session,
        extra: [Provider<SaleRepository>.value(value: sales)],
      ));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Supprimer'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Supprimer'));
      await tester.pumpAndSettle();
      expect(find.text('Supprimer la vente'), findsOneWidget);
      expect(find.textContaining('Les quantités en stock seront restaurées'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
      await tester.pumpAndSettle();
      expect(backend.requests.where((r) => r.method == 'DELETE').single.path, '/api/user-stock/sales/s-3');
      expect(find.text('Vente SL-20260930-0001 supprimée'), findsOneWidget);
    });
  });

  group('detail and edit', () {
    test('mark as paid sends the total and keeps the lines’ skus', () async {
      final model = SaleDetailViewModel(sales: sales, saleId: 's-2');
      addTearDown(model.dispose);
      await model.load();
      expect(model.sale!.items.first.sku, 'PRD-001');
      await model.markPaid();
      expect(backend.lastBody('PUT', '/api/user-stock/sales/s-2'), {'amountPaid': 12900.0});
      expect(model.sale!.isPaid, isTrue);
      expect(model.sale!.items.first.sku, 'PRD-001');
    });

    test('Partielle needs an amount between nothing and everything', () async {
      final model = EditSaleViewModel(sales: sales, saleId: 's-3', initial: Sale.fromJson(_pending));
      addTearDown(model.dispose);
      model.setStatus(PaymentStatus.partial);
      expect(model.partialProblem, PartialProblem.missing);
      expect(model.canSave, isFalse);
      model.paid.controller.text = '4200';
      expect(model.partialProblem, PartialProblem.notBelowTotal);
      model.paid.controller.text = '1500';
      expect(model.partialProblem, isNull);
      expect(model.changesAmount, isTrue);
      await model.save();
      expect(backend.lastBody('PUT', '/api/user-stock/sales/s-3'), {'amountPaid': 1500.0});
    });

    test('a notes-only edit leaves the money alone', () async {
      final model = EditSaleViewModel(sales: sales, saleId: 's-1', initial: Sale.fromJson(_paid));
      addTearDown(model.dispose);
      expect(model.canSave, isFalse, reason: 'nothing changed');
      model.notes.controller.text = 'Emballage cadeau';
      expect(model.canSave, isTrue);
      await model.save();
      expect(backend.lastBody('PUT', '/api/user-stock/sales/s-1'), {'notes': 'Emballage cadeau'});
    });

    test('back to pending takes the money out, and says so', () async {
      final model = EditSaleViewModel(sales: sales, saleId: 's-1', initial: Sale.fromJson(_paid));
      addTearDown(model.dispose);
      model.setStatus(PaymentStatus.pending);
      expect(model.newAmountPaid, 0);
      expect(model.changesAmount, isTrue);
    });
  });

  group('the new-sale form', () {
    test('the amount follows the total until typed, and *Payée en totalité* resets it', () async {
      final model = NewSaleViewModel(sales: sales, clients: clients, products: products);
      addTearDown(model.dispose);
      await model.load();
      final parfum = model.sellableProducts.firstWhere((p) => p.id == 'p-parfum');
      model.addLine(parfum);
      expect(model.paid.value, '4200');
      expect(model.paymentStatus, PaymentStatus.paid);
      model.addLine(parfum);
      expect(model.paid.value, '8400');
      model.paid.controller.text = '3000';
      expect(model.paymentStatus, PaymentStatus.partial);
      model.setLineQuantity(0, 3);
      expect(model.paid.value, '3000', reason: 'a typed amount is not overwritten');
      model.payInFull();
      expect(model.paid.value, '12600');
    });

    test('a variant product is sold by variant, and not over its stock', () async {
      final model = NewSaleViewModel(sales: sales, clients: clients, products: products);
      addTearDown(model.dispose);
      await model.load();
      final robe = model.sellableProducts.firstWhere((p) => p.id == 'p-robe');
      model.addLine(robe, robe.variants.first);
      model.setLineQuantity(0, 4);
      expect(model.overstockedLines, hasLength(1));
      expect(model.canSubmit, isFalse);
      model.setLineQuantity(0, 3);
      expect(model.canSubmit, isTrue);
    });

    test('a half-typed phone blocks the sale', () async {
      final model = NewSaleViewModel(sales: sales, clients: clients, products: products);
      addTearDown(model.dispose);
      await model.load();
      model.addLine(model.sellableProducts.firstWhere((p) => p.id == 'p-parfum'));
      model.phone.controller.text = '0770 33';
      expect(model.phoneIncomplete, isTrue);
      expect(model.canSubmit, isFalse);
      model.phone.controller.text = '';
      expect(model.canSubmit, isTrue, reason: 'the customer is optional');
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
          Provider<SaleRepository>.value(value: sales),
          Provider<ProductRepository>.value(value: products),
          Provider<ClientRepository>.value(value: clients),
          Provider<OrderRepository>.value(value: OrderRepository(api: apiForTest(dio: Dio()))),
        ],
      ));
      await tester.pumpAndSettle();
    }

    for (final language in AppLanguage.values) {
      testWidgets('list in ${language.code}', (tester) async {
        await pump(tester, const SalesScreen(), language);
        expect(tester.takeException(), isNull);
        // Below the figures and filters at this height.
        await tester.scrollUntilVisible(find.text('SL-20260930-0001'), 200, scrollable: find.byType(Scrollable).first);
        expect(tester.takeException(), isNull);
        expect(find.text('SL-20261001-0003'), findsOneWidget);
      });

      testWidgets('empty list in ${language.code}', (tester) async {
        backend.sales = [];
        await pump(tester, const SalesScreen(), language);
        expect(tester.takeException(), isNull);
      });

      testWidgets('filters in ${language.code}', (tester) async {
        await pump(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSaleFiltersSheet(context, current: const SaleFilters(hasRemaining: true)),
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

      testWidgets('detail in ${language.code}', (tester) async {
        await pump(tester, const SaleDetailScreen(saleId: 's-2'), language);
        expect(tester.takeException(), isNull);
        expect(find.text('PRD-001'), findsOneWidget);
      });

      testWidgets('edit in ${language.code}', (tester) async {
        await pump(tester, EditSaleScreen(saleId: 's-2', initial: Sale.fromJson(_partial)), language);
        expect(tester.takeException(), isNull);
        expect(find.text('6900'), findsOneWidget, reason: 'Partielle starts from what was received');
      });

      testWidgets('new sale in ${language.code}', (tester) async {
        await pump(tester, const NewSaleScreen(), language);
        // The fourth field is the product search.
        await tester.enterText(find.byType(TextField).at(3), 'parf');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Parfum Oud 50 ml'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('4200'), findsWidgets);
      });
    }
  });
}

const _paid = {
  'id': 's-1',
  'saleNumber': 'SL-20261001-0003',
  'customerName': 'Amina Belkacem',
  'customerPhone': '0550987654',
  'subtotal': '7300.00',
  'discount': '0.00',
  'tax': '0.00',
  'total': '7300.00',
  'amountPaid': '7300.00',
  'paymentMethod': 'cash',
  'paymentStatus': 'paid',
  'notes': null,
  'saleDate': '2026-10-01T10:00:00.000Z',
  'items': [
    {'id': 'i1', 'productId': 'p-robe', 'productName': 'Robe satin - Noir', 'quantity': 1, 'unitPrice': '2400.00', 'discount': '0.00', 'total': '2400.00'},
    {'id': 'i2', 'productId': 'p-parfum', 'productName': 'Parfum Oud 50 ml', 'quantity': 1, 'unitPrice': '4900.00', 'discount': '0.00', 'total': '4900.00'},
  ],
};

const _partial = {
  'id': 's-2',
  'saleNumber': 'SL-20261001-0002',
  'customerName': 'Karim Djaballah',
  'customerPhone': '0550987654',
  'subtotal': '12900.00',
  'discount': '0.00',
  'tax': '0.00',
  'total': '12900.00',
  'amountPaid': '6900.00',
  'paymentMethod': 'transfer',
  'paymentStatus': 'partial',
  'notes': 'Reste 6 000 DA à encaisser à la prochaine visite.',
  'saleDate': '2026-10-01T09:00:00.000Z',
  'items': [
    {'id': 'i3', 'productId': 'p-robe', 'productName': 'Robe satin - Noir', 'quantity': 2, 'unitPrice': '2400.00', 'discount': '200.00', 'total': '4600.00', 'product': {'id': 'p-robe', 'name': 'Robe satin', 'sku': 'PRD-001'}},
    {'id': 'i4', 'productId': 'p-parfum', 'productName': 'Parfum Oud 50 ml', 'quantity': 1, 'unitPrice': '4200.00', 'discount': '0.00', 'total': '4200.00', 'product': {'id': 'p-parfum', 'name': 'Parfum Oud 50 ml', 'sku': 'PRD-002'}},
    {'id': 'i5', 'productId': 'p-sac', 'productName': 'Sac cuir camel', 'quantity': 1, 'unitPrice': '4300.00', 'discount': '200.00', 'total': '4100.00', 'product': {'id': 'p-sac', 'name': 'Sac cuir camel', 'sku': 'PRD-003'}},
  ],
};

const _pending = {
  'id': 's-3',
  'saleNumber': 'SL-20260930-0001',
  'customerName': null,
  'subtotal': '4200.00',
  'discount': '0.00',
  'tax': '0.00',
  'total': '4200.00',
  'amountPaid': '0.00',
  'paymentMethod': 'ccp',
  'paymentStatus': 'pending',
  'saleDate': '2026-09-30T15:00:00.000Z',
  'items': [
    {'id': 'i6', 'productId': 'p-parfum', 'productName': 'Parfum Oud 50 ml', 'quantity': 1, 'unitPrice': '4200.00', 'discount': '0.00', 'total': '4200.00'},
  ],
};

final _extra = <String, dynamic>{
  ..._pending,
  'id': 's-4',
  'saleNumber': 'SL-20260929-0001',
};

/// The sale, product and client routes, answered in their documented shapes.
class _Backend implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  List<Map<String, dynamic>> sales = [_paid, _partial, _pending];
  int? total;

  /// What the next `offset > 0` page answers.
  List<Map<String, dynamic>> nextPage = const [];

  /// What `DELETE /sales/{id}` answers — 200, 400, 404.
  int deleteStatus = 200;

  Map<String, dynamic> lastBody(String method, String path) {
    final r = requests.lastWhere((r) => r.method == method && r.path == path);
    return Map<String, dynamic>.from(r.data is String ? jsonDecode(r.data as String) : r.data as Map);
  }

  Map<String, String> lastQuery(String path) =>
      requests.lastWhere((r) => r.path == path).queryParameters.map((k, v) => MapEntry(k, '$v'));

  dynamic _answer(RequestOptions o) {
    final p = o.path.replaceFirst('/api/user-stock', '');
    final m = o.method;
    if (p == '/sales' && m == 'GET') {
      final offset = int.tryParse('${o.queryParameters['offset'] ?? 0}') ?? 0;
      return {'sales': offset > 0 ? nextPage : sales, 'total': total ?? sales.length};
    }
    if (p == '/sales/stats') {
      return {
        'stats': {'totalSales': 48, 'totalRevenue': 412600, 'paidSales': 40, 'pendingSales': 5, 'averageOrderValue': 8595.83},
        'topProducts': [],
      };
    }
    if (p == '/sales' && m == 'POST') {
      return (201, {'sale': {..._pending, 'id': 's-9', 'saleNumber': 'SL-20261001-0004'}});
    }
    if (p.startsWith('/sales/') && m == 'GET') {
      final id = p.substring('/sales/'.length);
      final sale = sales.where((s) => s['id'] == id).firstOrNull;
      return sale == null ? (404, {'error': 'Sale not found'}) : {'sale': sale};
    }
    if (p.startsWith('/sales/') && m == 'PUT') {
      final id = p.substring('/sales/'.length);
      final base = sales.firstWhere((s) => s['id'] == id);
      final body = Map<String, dynamic>.from(o.data is String ? jsonDecode(o.data as String) : o.data as Map);
      final total = double.parse(base['total'] as String);
      final paid = (body['amountPaid'] as num?)?.toDouble() ?? double.parse(base['amountPaid'] as String);
      return {
        'sale': {
          ...base,
          'amountPaid': paid.toStringAsFixed(2),
          'paymentStatus': paid <= 0 ? 'pending' : paid >= total ? 'paid' : 'partial',
          'notes': body['notes'] ?? base['notes'],
          // The update answers without each line's product.
          'items': [for (final i in base['items'] as List) {...i as Map}..remove('product')],
        },
      };
    }
    if (p.startsWith('/sales/') && m == 'DELETE') {
      return switch (deleteStatus) {
        200 => {'success': true},
        400 => (400, {'error': 'Cannot delete a sale with recorded payments'}),
        _ => (404, {'error': 'Sale not found'}),
      };
    }
    if (p == '/products') {
      return {
        'products': [
          {
            'id': 'p-robe', 'sku': 'PRD-001', 'name': 'Robe satin', 'costPrice': '1200.00', 'sellingPrice': '2400.00',
            'quantity': 3, 'hasVariants': true, 'isActive': true,
            'variants': [
              {'id': 'v-noir', 'name': 'Noir', 'sellingPrice': '2400.00', 'costPrice': '1200.00', 'quantity': 3, 'isActive': true},
            ],
          },
          {
            'id': 'p-parfum', 'sku': 'PRD-002', 'name': 'Parfum Oud 50 ml', 'costPrice': '2000.00',
            'sellingPrice': '4200.00', 'quantity': 5, 'hasVariants': false, 'isActive': true,
          },
        ],
        'total': 2,
      };
    }
    if (p == '/clients') {
      return {
        'clients': [
          {'id': 'c1', 'name': 'Amina Belkacem', 'phone': '0550987654'},
        ],
      };
    }
    return (404, {'error': 'Not found', 'message': 'Not found'});
  }

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    final answer = _answer(options);
    final (status, body) = answer is (int, Object) ? answer : (200, answer);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

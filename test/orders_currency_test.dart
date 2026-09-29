import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/client.dart';
import 'package:djaber_mobile/data/models/order.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/models/product_filters.dart';
import 'package:djaber_mobile/data/repositories/client_repository.dart';
import 'package:djaber_mobile/data/repositories/delivery_repository.dart';
import 'package:djaber_mobile/data/repositories/order_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/presentation/screens/orders/new_order_screen.dart';
import 'package:djaber_mobile/presentation/screens/orders/order_detail_screen.dart';
import 'package:djaber_mobile/presentation/screens/orders/orders_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// Every amount in the Orders flow says `DA` once. `Money.exact` already ends
/// with the unit, and the screens were adding it again — `1 500 DA DA`.
void main() {
  late SessionViewModel session;

  setUp(() async {
    session = await sessionForTest();
    session.markBootComplete();
  });

  tearDown(() => session.dispose());

  final order = Order(
    id: 'o-1',
    orderNumber: 'ORD-20260929-0001',
    clientName: 'Amina Belkacem',
    clientPhone: '0555123456',
    subtotal: 3000,
    deliveryFee: 700,
    total: 3700,
    amountPaid: 1000,
    orderDate: DateTime(2026, 9, 29),
    items: const [
      OrderItem(id: 'i-1', productId: 'p-1', productName: 'Robe satin', quantity: 2, unitPrice: 1500, total: 3000),
    ],
  );

  Future<void> pump(WidgetTester tester, Widget screen) async {
    // Wide on purpose: at 411 three Orders rows overflow (the list row's
    // header and buttons, the wizard's steps) — a separate, known layout
    // issue (brief §27.13). This test is about the unit only.
    tester.view.physicalSize = const Size(700, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      authHost(
        screen,
        session,
        extra: [
          Provider<OrderRepository>(create: (_) => _Orders(order)),
          Provider<DeliveryRepository>(create: (_) => _Delivery()),
          Provider<ClientRepository>(create: (_) => _Clients()),
          Provider<ProductRepository>(create: (_) => _Products()),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Every string drawn under [root], whether a `Text` or a `RichText`.
  List<String> textsUnder(WidgetTester tester, Finder root) => [
        for (final element in find.descendant(of: root, matching: find.byType(RichText)).evaluate())
          (element.widget as RichText).text.toPlainText(),
      ];

  int unitCount(String s) => RegExp(r'\bDA\b').allMatches(s).length;

  /// `DA DA`, however it is spaced — the bug itself.
  bool doubled(String s) => RegExp(r'\bDA\s*DA\b').hasMatch(s);

  void expectEachAmountSaysDaOnce(WidgetTester tester) {
    final all = textsUnder(tester, find.byType(MaterialApp));
    expect(all.where((s) => unitCount(s) > 0), isNotEmpty, reason: 'no amount was drawn at all');
    // A line may carry two amounts (`PAYÉ 1 000 DA · RESTANT 2 700 DA`); what
    // it may not do is say the unit twice for one of them.
    for (final s in all) {
      expect(doubled(s), isFalse, reason: '"$s"');
    }
    // A tile draws its figure and its unit apart — together, still once.
    for (final tile in find.byType(KpiTile).evaluate()) {
      final joined = textsUnder(tester, find.byWidget(tile.widget)).join(' ');
      expect(unitCount(joined), lessThanOrEqualTo(1), reason: '"$joined"');
    }
  }

  testWidgets('order detail', (tester) async {
    await pump(tester, OrderDetailScreen(orderId: order.id, initial: order));
    expectEachAmountSaysDaOnce(tester);
  });

  testWidgets('orders list', (tester) async {
    await pump(tester, const OrdersScreen());
    expectEachAmountSaysDaOnce(tester);
  });

  testWidgets('new order', (tester) async {
    await pump(tester, const NewOrderScreen());
    expectEachAmountSaysDaOnce(tester);
  });
}

class _Orders extends OrderRepository {
  _Orders(this.order) : super(api: apiForTest());

  final Order order;

  @override
  Future<Result<Order>> get(String orderId) async => Result.success(order);

  @override
  Future<Result<OrderStats>> stats({String period = 'year'}) async =>
      const Result.success(OrderStats(totalOrders: 1, totalRevenue: 3700, pending: 1));

  @override
  Future<Result<OrderPage>> list({
    String? search,
    OrderStatus? status,
    ConfirmationStatus? confirmationStatus,
    PaymentStatus? paymentStatus,
    bool hasRemaining = false,
    DateTime? startDate,
    DateTime? endDate,
    double? minTotal,
    double? maxTotal,
    String? clientId,
    int limit = 50,
    int offset = 0,
  }) async =>
      Result.success((orders: [order], total: 1));
}

class _Delivery extends DeliveryRepository {
  _Delivery() : super(api: apiForTest());

  @override
  Future<Result<List<Wilaya>>> wilayas() async => const Result.success([
        Wilaya(id: 16, code: '16', nameAr: 'الجزائر', nameFr: 'Alger', nameEn: 'Algiers'),
      ]);

  @override
  Future<Result<DeliveryQuote>> quote({required int wilayaId, bool isStopdesk = false}) async =>
      const Result.success((fee: 700, source: 'custom'));
}

class _Clients extends ClientRepository {
  _Clients() : super(api: apiForTest());

  @override
  Future<Result<List<Client>>> list({
    String? search,
    String? phone,
    bool? isActive,
    ClientSource? source,
    int? minOrders,
    int? maxOrders,
    double? minSpent,
    double? maxSpent,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      const Result.success([]);
}

class _Products extends ProductRepository {
  _Products() : super(api: apiForTest());

  @override
  Future<Result<ProductPage>> list({
    String? search,
    String? categoryId,
    bool lowStock = false,
    ProductFilters filters = const ProductFilters(),
    int limit = 50,
    int offset = 0,
  }) async =>
      const Result.success((products: <Product>[], total: 0));
}

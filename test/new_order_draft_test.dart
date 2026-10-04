import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/client.dart';
import 'package:djaber_mobile/data/models/order.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/models/product_filters.dart';
import 'package:djaber_mobile/data/repositories/client_repository.dart';
import 'package:djaber_mobile/data/repositories/delivery_repository.dart';
import 'package:djaber_mobile/data/repositories/order_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/presentation/viewmodels/form_draft_store.dart';
import 'package:djaber_mobile/presentation/viewmodels/new_order_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// A half-typed order surviving the app being left.
///
/// Leaving replays the splash on the way back (`SessionViewModel.replaySplash`),
/// and the router then builds `New order` from scratch — so everything the
/// merchant had typed went with it. The form now writes to the
/// [FormDraftStore] on every change and reads it back when it is rebuilt.
void main() {
  late SessionViewModel session;
  late FormDraftStore drafts;

  setUp(() async {
    session = await sessionForTest();
    // As the app is once the splash has handed over. Without this the boot
    // gate stays down, `release` never fires, and every draft would look kept
    // — which would make these tests pass for the wrong reason.
    session.markBootComplete();
    drafts = FormDraftStore(session: session);
  });

  tearDown(() {
    drafts.dispose();
    session.dispose();
  });

  Product product(String id, String name, {int quantity = 10, double price = 2400}) =>
      Product.fromJson({
        'id': id,
        'sku': id.toUpperCase(),
        'name': name,
        'sellingPrice': '$price',
        'quantity': quantity,
        'isActive': true,
      });

  const amina = Client(id: 'c-1', name: 'Amina Belkacem', phone: '0555123456');

  NewOrderViewModel build(List<Product> catalogue) => NewOrderViewModel(
        orders: _Orders(),
        clients: _Clients(const [amina]),
        products: _Products(catalogue),
        delivery: _Delivery(),
        drafts: drafts,
      );

  testWidgets('everything typed and chosen comes back when the screen is '
      'built again', (tester) async {
    final catalogue = [product('p-1', 'Robe satin'), product('p-2', 'Sac cuir')];

    final first = build(catalogue);
    await first.load();
    first.name.controller.text = 'Yacine Mansouri';
    first.phone.controller.text = '0661 45 78 90';
    first.address.controller.text = 'Cité 20 Août';
    first.notes.controller.text = 'Sonner deux fois';
    first.paid.controller.text = '1000';
    await first.setWilaya(16);
    await first.setStopdesk(true);
    first.setStatus(OrderStatus.confirmed);
    first.setPaymentMethod(PaymentMethod.ccp);
    first.addLine(catalogue[0]);
    first.addLine(catalogue[0]); // same line twice — quantity 2
    first.addLine(catalogue[1]);
    first.setLinePrice(1, 3000);
    // The splash took the screen, so the draft is kept rather than released.
    session.replaySplash();
    first.dispose();

    final second = build(catalogue);
    await second.load();

    expect(second.name.value, 'Yacine Mansouri');
    expect(second.phone.value, '0661 45 78 90');
    expect(second.address.value, 'Cité 20 Août');
    expect(second.notes.value, 'Sonner deux fois');
    expect(second.amountPaid, 1000);
    expect(second.wilayaId, 16);
    expect(second.isStopdesk, isTrue);
    expect(second.status, OrderStatus.confirmed);
    expect(second.paymentMethod, PaymentMethod.ccp);

    expect(second.lines.length, 2);
    expect(second.lines.first.product.id, 'p-1');
    expect(second.lines.first.quantity, 2, reason: 'the doubled line kept its count');
    expect(second.lines.last.product.id, 'p-2');
    expect(second.lines.last.unitPrice, 3000, reason: 'an edited price is kept');
    expect(second.droppedDraftLines, 0);

    second.dispose();
  });

  testWidgets('a chosen client comes back as the client, not as typed text',
      (tester) async {
    final first = build([product('p-1', 'Robe satin')]);
    await first.load();
    first.setClient(amina);
    session.replaySplash();
    first.dispose();

    final second = build([product('p-1', 'Robe satin')]);
    await second.load();

    expect(second.client?.id, 'c-1');
    expect(second.clientName, 'Amina Belkacem');
    expect(second.clientPhone, '0555123456');

    second.dispose();
  });

  testWidgets('a line whose product has gone is dropped and said out loud',
      (tester) async {
    final before = [product('p-1', 'Robe satin'), product('p-2', 'Sac cuir')];
    final first = build(before);
    await first.load();
    first.addLine(before[0]);
    first.addLine(before[1]);
    session.replaySplash();
    first.dispose();

    // The merchant was away; one product was deleted in the meantime.
    final second = build([product('p-1', 'Robe satin')]);
    await second.load();

    expect(second.lines.length, 1);
    expect(second.lines.single.product.id, 'p-1');
    expect(second.droppedDraftLines, 1, reason: 'the total changed — say so');

    second.acknowledgeDroppedLines();
    expect(second.droppedDraftLines, 0);

    second.dispose();
  });

  testWidgets('leaving the form deliberately throws the draft away',
      (tester) async {
    final first = build([product('p-1', 'Robe satin')]);
    await first.load();
    first.name.controller.text = 'Yacine Mansouri';
    // No `replaySplash`: the merchant navigated away rather than leaving the app,
    // and a form they walked out of should be empty next time.
    first.dispose();

    final second = build([product('p-1', 'Robe satin')]);
    await second.load();

    expect(second.name.value, isEmpty);
    expect(second.lines, isEmpty);

    second.dispose();
  });
}

class _Orders extends OrderRepository {
  _Orders() : super(api: apiForTest());
}

class _Clients extends ClientRepository {
  _Clients(this.rows) : super(api: apiForTest());

  final List<Client> rows;

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
      Result.success(rows);
}

class _Products extends ProductRepository {
  _Products(this.rows) : super(api: apiForTest());

  final List<Product> rows;

  @override
  Future<Result<ProductPage>> list({
    String? search,
    String? categoryId,
    bool lowStock = false,
    ProductFilters filters = const ProductFilters(),
    int limit = 50,
    int offset = 0,
  }) async =>
      Result.success((products: rows, total: rows.length));
}

class _Delivery extends DeliveryRepository {
  _Delivery() : super(api: apiForTest());

  @override
  Future<Result<List<Wilaya>>> wilayas() async => const Result.success([
        Wilaya(id: 16, code: '16', nameAr: 'الجزائر', nameFr: 'Alger', nameEn: 'Algiers'),
      ]);

  @override
  Future<Result<DeliveryQuote>> quote({
    required int wilayaId,
    bool isStopdesk = false,
  }) async =>
      const Result.success((fee: 700, source: 'custom'));
}

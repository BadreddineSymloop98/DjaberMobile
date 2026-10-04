import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/constants/api_endpoints.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/product_filters.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/presentation/screens/products/product_filters_sheet.dart';
import 'package:djaber_mobile/presentation/screens/products/products_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/products_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// `17 — Produits`: the web's filter panel — status, and the five ranges —
/// behind a *Filtres* button, as on Clients. The chips (all, low stock, one
/// category) stay as the frame draws them.
void main() {
  group('what is sent', () {
    late List<RequestOptions> sent;
    late ProductRepository repo;

    setUp(() {
      sent = [];
      final dio = Dio()..httpClientAdapter = _Canned(sent);
      repo = ProductRepository(api: apiForTest(dio: dio));
    });

    Map<String, dynamic> query() => sent.single.queryParameters;

    test('no filter sends nothing extra — the server lists active products', () async {
      await repo.list();
      expect(sent.single.path, Api.products);
      expect(
        query().keys,
        isNot(anyOf(contains('isActive'), contains('minPrice'), contains('minProfit'))),
      );
    });

    test('inactive asks for the deleted products only', () async {
      await repo.list(filters: const ProductFilters(status: ProductStatusFilter.inactive));
      expect(query()['isActive'], 'false');
    });

    test('each range goes out under the name the API reads', () async {
      await repo.list(
        filters: const ProductFilters(
          minPrice: 1000,
          maxPrice: 5000,
          minCost: 500,
          maxCost: 2500.5,
          minQty: 2,
          maxQty: 40,
          minProfit: -200,
          maxProfit: 3000,
          minMargin: -10,
          maxMargin: 60,
        ),
      );
      expect(query(), containsPair('minPrice', 1000));
      expect(query(), containsPair('maxPrice', 5000));
      expect(query(), containsPair('minCost', 500));
      expect(query(), containsPair('maxCost', 2500.5));
      expect(query(), containsPair('minQty', 2));
      expect(query(), containsPair('maxQty', 40));
      expect(query(), containsPair('minProfit', -200));
      expect(query(), containsPair('maxProfit', 3000));
      expect(query(), containsPair('minMargin', -10));
      expect(query(), containsPair('maxMargin', 60));
    });

    test('a price, cost or quantity of 0 is not sent — the server ignores it anyway', () async {
      await repo.list(filters: const ProductFilters(minPrice: 0, minCost: 0, minQty: 0));
      expect(query().keys, isNot(anyOf(contains('minPrice'), contains('minCost'), contains('minQty'))));
    });

    test('a profit or margin of 0 is a real bound and is sent', () async {
      await repo.list(filters: const ProductFilters(minProfit: 0, minMargin: 0));
      expect(query(), containsPair('minProfit', 0));
      expect(query(), containsPair('minMargin', 0));
    });
  });

  group('counting what is applied, as the web badge does', () {
    test('each range counts once, and so does the status', () {
      expect(const ProductFilters().activeCount, 0);
      expect(const ProductFilters().isEmpty, isTrue);
      expect(const ProductFilters(minPrice: 100, maxPrice: 900).activeCount, 1);
      expect(
        const ProductFilters(status: ProductStatusFilter.inactive, maxQty: 5, minMargin: -5).activeCount,
        3,
      );
    });

    test('a price range of 0 is no filter at all', () {
      expect(const ProductFilters(minPrice: 0, maxCost: 0).isEmpty, isTrue);
    });
  });

  /// The input inside the AppTextField with this label — the label itself is
  /// drawn outside the TextField, upper-cased.
  Finder field(String label) => find.descendant(
        of: find.byWidgetPredicate((w) => w is AppTextField && w.label == label),
        matching: find.byType(TextField),
      );

  group('the list', () {
    late SessionViewModel session;

    setUp(() async {
      session = await sessionForTest();
      session.markBootComplete();
    });

    tearDown(() => session.dispose());

    test('applying filters reloads the list with them', () async {
      final products = _Recording();
      final model = ProductsViewModel(
        products: products,
        catalogue: FakeCatalogueRepository(),
        dashboard: FakeDashboardRepository(),
      );
      addTearDown(model.dispose);
      await model.load();

      const filters = ProductFilters(minPrice: 1000, status: ProductStatusFilter.inactive);
      await model.applyFilters(filters);

      expect(model.filters, filters);
      expect(products.seen.last, filters);
      expect(model.isCatalogueEmpty, isFalse, reason: 'filtered to nothing is not an empty catalogue');
    });

    testWidgets('Filtres opens the sheet; a range applied goes to the server', (tester) async {
      tester.view.physicalSize = const Size(411, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final products = _Recording();

      await tester.pumpWidget(
        authHost(
          const ProductsScreen(),
          session,
          extra: [
            Provider<ProductRepository>.value(value: products),
            Provider<CatalogueRepository>(create: (_) => FakeCatalogueRepository()),
            Provider<DashboardRepository>(create: (_) => FakeDashboardRepository()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filtres'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Prix de vente (DA) · min'), '1000');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appliquer les filtres'));
      await tester.pumpAndSettle();

      expect(products.seen.last.minPrice, 1000);
      expect(find.text('Filtres · 1'), findsOneWidget);
    });

    testWidgets('a minimum above the maximum cannot be applied', (tester) async {
      tester.view.physicalSize = const Size(411, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        authHost(
          const ProductsScreen(),
          session,
          extra: [
            Provider<ProductRepository>.value(value: _Recording()),
            Provider<CatalogueRepository>(create: (_) => FakeCatalogueRepository()),
            Provider<DashboardRepository>(create: (_) => FakeDashboardRepository()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filtres'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Quantité · min'), '50');
      await tester.enterText(field('Quantité · max'), '10');
      await tester.pumpAndSettle();

      final apply = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Appliquer les filtres'));
      expect(apply.onPressed, isNull);
      expect(find.text('Doit être au moins le minimum'), findsOneWidget);
    });

    // The Arabic labels are the longest, in half-width fields, on the
    // narrowest handset this market ships — where a translation breaks first.
    for (final language in AppLanguage.values) {
      testWidgets('the sheet lays out in ${language.code} at 320', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          authHost(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => showProductFiltersSheet(context, current: const ProductFilters()),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
            session,
            locale: language.locale,
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(AppTextField), findsNWidgets(10));
      });
    }
  });
}

/// Records the filters every list call carried.
class _Recording extends FakeProductRepository {
  final seen = <ProductFilters>[];

  @override
  Future<Result<ProductPage>> list({
    String? search,
    String? categoryId,
    bool lowStock = false,
    ProductFilters filters = const ProductFilters(),
    int limit = 50,
    int offset = 0,
  }) {
    seen.add(filters);
    return super.list(search: search, categoryId: categoryId, lowStock: lowStock, filters: filters);
  }
}

class _Canned implements HttpClientAdapter {
  _Canned(this.sent);

  final List<RequestOptions> sent;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options);
    return ResponseBody.fromString(
      '{"products":[],"total":0}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

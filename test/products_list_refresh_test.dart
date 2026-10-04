import 'dart:async';

import 'package:djaber_mobile/app/route_observer.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/models/product_filters.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/products/products_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// `17 — Produits` refreshing when the screen above it closes.
///
/// Reported from the handset: *"when you add a product with a picture, the
/// product doesn't show straight away on the list, until you refresh."* The
/// list reloaded only when `Add product` popped **with a value**, and that is
/// one of several ways that form can close — it also leaves through the
/// router's fallback, which completes no future at all. Adding a photo is what
/// made it visible: the picker sends the app to the background on the way.
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  Product product(String name) => Product.fromJson({
        'id': name,
        'sku': name.toUpperCase(),
        'name': name,
        'costPrice': '1000.00',
        'sellingPrice': '1500.00',
        'quantity': 3,
      });

  /// The list, with a stand-in for whatever is pushed on top of it.
  Future<L10n> pump(WidgetTester tester, _Products products) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: Routes.products,
      // As `router.dart` wires it: the list refreshes off this.
      observers: [appRouteObserver],
      routes: [
        GoRoute(
          path: Routes.productNew,
          builder: (_, _) => const Scaffold(body: Text('Add product')),
        ),
        GoRoute(path: Routes.products, builder: (_, _) => const ProductsScreen()),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(routerHost(
      router,
      session,
      extra: [
        Provider<ProductRepository>.value(value: products),
        Provider<CatalogueRepository>.value(value: FakeCatalogueRepository()),
        Provider<DashboardRepository>.value(value: FakeDashboardRepository()),
      ],
    ));
    await tester.pumpAndSettle();
    return L10n.delegate.load(const Locale('fr'));
  }

  testWidgets('a product created on the form above is on the list as soon as '
      'that form closes, whatever it pops', (tester) async {
    final products = _Products([product('Sac cuir')]);
    final l10n = await pump(tester, products);

    expect(find.text('Sac cuir'), findsOneWidget);

    await tester.tap(find.text(l10n.productsAdd));
    await tester.pumpAndSettle();
    expect(find.text('Add product'), findsOneWidget);

    // The product is created, photo and all, and the form closes reporting
    // nothing — the path the old pop value never covered.
    products.rows.add(product('Ceinture'));
    GoRouter.of(tester.element(find.text('Add product'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Ceinture'), findsOneWidget);
    expect(find.text('Sac cuir'), findsOneWidget);
  });

  testWidgets('and a bottom sheet closing does not refetch — only a screen '
      'above does', (tester) async {
    final products = _Products([product('Sac cuir')]);
    await pump(tester, products);
    final before = products.listCalls;

    // A sheet is a PopupRoute, not a PageRoute, so the observer stays quiet.
    final context = tester.element(find.byType(ProductsScreen));
    unawaited(showModalBottomSheet<void>(
      context: context,
      builder: (_) => const SizedBox(height: 100),
    ));
    await tester.pumpAndSettle();
    Navigator.of(context, rootNavigator: true).pop();
    await tester.pumpAndSettle();

    expect(products.listCalls, before);
  });
}

/// A catalogue whose rows the test can change between requests.
class _Products extends ProductRepository {
  _Products(this.rows) : super(api: apiForTest());

  final List<Product> rows;
  int listCalls = 0;

  @override
  Future<Result<ProductPage>> list({
    String? search,
    String? categoryId,
    bool lowStock = false,
    ProductFilters filters = const ProductFilters(),
    int limit = 50,
    int offset = 0,
  }) async {
    listCalls++;
    return Result.success((
      products: List<Product>.from(rows),
      total: rows.length,
    ));
  }
}

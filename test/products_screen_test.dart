import 'package:djaber_mobile/core/utils/money.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/catalogue.dart';
import 'package:djaber_mobile/data/models/dashboard_stats.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/products/add_product_screen.dart';
import 'package:djaber_mobile/presentation/screens/products/products_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_filter_chip.dart';
import 'package:djaber_mobile/presentation/widgets/app_select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/fake_repositories.dart';

/// `17 — Produits` and `18 — Ajouter un produit`.
///
/// The layout sweep is the part that has actually caught things on this
/// project — the drawer's Arabic header overflowed by 14px and the splash
/// lockup by 29, and both were found by *rendering* the screen in Arabic at
/// 320 rather than by reading it. Changa's metrics are not Geist's and the
/// whole layout mirrors, so these two screens get the same treatment before
/// they go anywhere near a handset.
void main() {
  final catalogue = <ProductCategory>[
    const ProductCategory(id: 'c-1', name: 'Robes', productCount: 12),
    const ProductCategory(id: 'c-2', name: 'Parfums', productCount: 4),
  ];

  final units = <ProductUnit>[
    const ProductUnit(
      id: 'u-1',
      name: 'Piece',
      abbreviation: 'pc',
      isDefault: true,
    ),
    const ProductUnit(id: 'u-2', name: 'Kilogram', abbreviation: 'kg'),
  ];

  final rows = <Product>[
    const Product(
      id: 'p-1',
      sku: 'PRD-001',
      name: 'Robe satin — Noir — M',
      sellingPrice: 2400,
      costPrice: 1500,
      // Out of stock, which is the row that carries `accent/alert`.
      quantity: 0,
      categoryId: 'c-1',
    ),
    const Product(
      id: 'p-2',
      sku: 'PRD-002',
      name: 'Parfum oud 50 ml',
      sellingPrice: 4200,
      costPrice: 3000,
      quantity: 3,
      // At the threshold, so `isLowStock` is true and the meta line carries
      // the threshold segment.
      minQuantity: 10,
      categoryId: 'c-2',
    ),
    const Product(
      id: 'p-3',
      sku: 'PRD-003',
      name: 'Sac cuir — Camel',
      sellingPrice: 7900,
      costPrice: 5000,
      quantity: 7,
    ),
  ];

  const stats = DashboardStats(
    totalProducts: 128,
    lowStockProducts: 3,
    // 1.24M — the frame's own figure, and the one that exercises the compact
    // form rather than the plain one.
    totalStockValue: 1240000,
  );

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    required Locale locale,
    required Size size,
    FakeProductRepository? products,
    FakeCatalogueRepository? catalogueRepo,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductRepository>.value(
            value: products ?? FakeProductRepository(rows: rows),
          ),
          Provider<CatalogueRepository>.value(
            value: catalogueRepo ??
                FakeCatalogueRepository(
                  categoryList: catalogue,
                  unitList: units,
                ),
          ),
          Provider<DashboardRepository>.value(
            value: FakeDashboardRepository(stats0: stats),
          ),
        ],
        // Above `MaterialApp`, not inside its builder. §22.6, three times
        // over: the theme is built while `MaterialApp` is being constructed,
        // so `Screen` has to be warm before that happens — a `ScreenInitializer`
        // in the builder runs too late and whichever test ran first failed.
        child: MediaQuery.fromView(
          view: tester.view,
          child: Builder(
            builder: (context) {
              Screen.update(MediaQuery.of(context));
              return MaterialApp(
                locale: locale,
                theme: AppTheme.build(locale),
                supportedLocales: AppLanguage.values.map((l) => l.locale),
                localizationsDelegates: const [
                  L10n.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: screen,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const sizes = <String, Size>{
    // The floor this market ships on — `Screen.isSmall` treats anything under
    // 360 as small, and it is where a longer translation breaks first.
    '320x640': Size(320, 640),
    '411x914': Size(411, 914),
  };

  group('layout', () {
    for (final language in AppLanguage.values) {
      for (final size in sizes.entries) {
        testWidgets('17 in ${language.code} at ${size.key}', (tester) async {
          await pump(
            tester,
            const ProductsScreen(),
            locale: language.locale,
            size: size.value,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('18 in ${language.code} at ${size.key}', (tester) async {
          await pump(
            tester,
            const AddProductScreen(),
            locale: language.locale,
            size: size.value,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('17 — Produits', () {
    testWidgets('the subtitle counts the catalogue, not the page', (
      tester,
    ) async {
      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );

      // Three rows on screen, 128 in the catalogue. The subtitle describes the
      // catalogue — it must not follow the list.
      final l10n = await L10n.delegate.load(const Locale('en'));
      expect(
        find.text(
          l10n.productsSummary(128, Money.shortLabel(1240000, 'en')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a row states the SKU, the price and its threshold', (
      tester,
    ) async {
      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );

      expect(find.text('Parfum oud 50 ml'), findsOneWidget);
      // `THRESHOLD 10` only appears when one is set; the third row has none.
      expect(find.textContaining('PRD-002 · 4,200 DA · THRESHOLD 10'),
          findsOneWidget);
      expect(find.textContaining('PRD-003 · 7,900 DA'), findsOneWidget);
      expect(find.textContaining('PRD-003 · 7,900 DA · '), findsNothing);
    });

    testWidgets('out of stock is said once, under the count', (tester) async {
      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );

      // The frames put the state in the meta line *as well*. It says it once,
      // where it belongs — as the label on the number it describes.
      expect(find.text('OUT OF STOCK'), findsOneWidget);
      expect(find.textContaining('PRD-001 · 2,400 DA · OUT'), findsNothing);
    });

    testWidgets('the chips are the merchant own categories, and they filter '
        'server-side', (tester) async {
      final products = FakeProductRepository(rows: rows);
      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
        products: products,
      );

      // Tous, Stock faible, then one per category — not the fixed three the
      // frames drew.
      expect(find.byType(AppFilterChip), findsNWidgets(4));
      expect(find.text('Robes'), findsOneWidget);
      expect(find.text('Parfums'), findsOneWidget);

      await tester.tap(find.text('Robes'));
      await tester.pumpAndSettle();

      // The category reached the *request*. This is the assertion that matters
      // — the rows would narrow either way, because the fake filters too, so a
      // filter that never left the client would still look right.
      expect(products.calls.last.categoryId, 'c-1');
      expect(find.text('Robe satin — Noir — M'), findsOneWidget);
      expect(find.text('Sac cuir — Camel'), findsNothing);

      await tester.tap(find.text('Low stock'));
      await tester.pumpAndSettle();
      expect(products.calls.last.lowStock, isTrue);
      expect(products.calls.last.categoryId, isNull);
    });

    testWidgets('an empty catalogue and an empty filter say different things', (
      tester,
    ) async {
      final l10n = await L10n.delegate.load(const Locale('en'));

      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
        products: FakeProductRepository(rows: const []),
      );
      expect(find.text(l10n.productsEmptyTitle), findsOneWidget);

      // Now a catalogue that is not empty, filtered down to nothing. Telling
      // this merchant to "add your first product" would be wrong.
      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
        products: FakeProductRepository(rows: rows),
      );
      await tester.enterText(
        find.byType(TextField).first,
        'nothing matches this',
      );
      await tester.pump(const Duration(milliseconds: 400)); // past the debounce
      await tester.pumpAndSettle();

      expect(find.text(l10n.productsNoMatchTitle), findsOneWidget);
      expect(find.text(l10n.productsEmptyTitle), findsNothing);
    });

    testWidgets('search is debounced, not sent per keystroke', (tester) async {
      final products = FakeProductRepository(rows: rows);
      await pump(
        tester,
        const ProductsScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
        products: products,
      );

      final before = products.calls.length;
      await tester.enterText(find.byType(TextField).first, 'r');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).first, 'ro');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField).first, 'rob');
      // Nothing sent yet — three keystrokes inside one window.
      expect(products.calls.length, before);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(products.calls.length, before + 1);
      expect(products.calls.last.search, 'rob');
    });
  });

  group('18 — Ajouter un produit', () {
    testWidgets('the title is just "Add Product"', (tester) async {
      await pump(
        tester,
        const AddProductScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );
      final l10n = await L10n.delegate.load(const Locale('en'));
      expect(find.text(l10n.productAddTitle), findsOneWidget);
    });

    testWidgets('ticking variants stops requiring a quantity', (tester) async {
      final l10n = await L10n.delegate.load(const Locale('en'));
      await pump(
        tester,
        const AddProductScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );

      // Fill everything except the quantity, then submit: the quantity is the
      // one field left invalid.
      await tester.enterText(find.byType(TextField).at(0), 'Robe');
      await tester.enterText(find.byType(TextField).at(1), 'PRD-009');
      await tester.enterText(find.byType(TextField).at(3), '1000');
      await tester.enterText(find.byType(TextField).at(4), '2000');
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.productAddSubmit));
      await tester.pumpAndSettle();
      expect(find.text(l10n.productErrRequired), findsWidgets);

      // The server drops that rule when the product has variants, and so does
      // the form — otherwise it refuses what the backend would accept.
      //
      // Scrolled to first: the checkbox is the last control on a form that is
      // taller than the viewport, so it sits below the fold on a real handset
      // too.
      await tester.ensureVisible(find.text(l10n.productHasVariants));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.productHasVariants));
      await tester.pumpAndSettle();
      expect(find.text(l10n.productErrRequired), findsNothing);
    });

    testWidgets('the threshold accepts an explicit zero', (tester) async {
      final l10n = await L10n.delegate.load(const Locale('en'));
      await pump(
        tester,
        const AddProductScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );

      // 0 means "no threshold" to the server, so it is a legitimate value —
      // `Validators.quantity`'s must-be-positive rule would have rejected it.
      await tester.enterText(find.byType(TextField).at(6), '0');
      await tester.pumpAndSettle();
      expect(find.text(l10n.productErrMustBePositive), findsNothing);
    });

    testWidgets('the pickers stay inert when there is nothing to pick', (
      tester,
    ) async {
      await pump(
        tester,
        const AddProductScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
        catalogueRepo: FakeCatalogueRepository(), // a fresh account
      );

      final fields = tester
          .widgetList<AppSelectField<String>>(
            find.byType(AppSelectField<String>),
          )
          .toList();
      expect(fields, hasLength(2));
      expect(fields.every((f) => f.enabled), isFalse);

      // And tapping one opens nothing rather than an empty sheet.
      await tester.tap(find.byType(AppSelectField<String>).first);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('a category can be chosen and then taken off again', (
      tester,
    ) async {
      final l10n = await L10n.delegate.load(const Locale('en'));
      await pump(
        tester,
        const AddProductScreen(),
        locale: const Locale('en'),
        size: const Size(411, 914),
      );

      await tester.tap(find.byType(AppSelectField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Robes'));
      await tester.pumpAndSettle();
      expect(find.text('Robes'), findsOneWidget);

      // The "none" row is always there, or an optional field could be set once
      // and never cleared.
      await tester.tap(find.byType(AppSelectField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.productCategoryNone).last);
      await tester.pumpAndSettle();
      expect(find.text('Robes'), findsNothing);
    });
  });
}

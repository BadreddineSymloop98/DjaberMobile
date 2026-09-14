import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_bottom_nav.dart';
import 'package:djaber_mobile/presentation/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// The custom bottom nav — `Bottom nav` (node `134:791`) — and the shell that
/// holds it.
///
/// Run against the real router, because the thing worth proving is that a tab
/// changes the route without stacking one destination on the last.
void main() {
  late SessionViewModel session;
  late AppRouter router;

  setUp(() async {
    session = await sessionForTest(prefsValues: {'onboarding_seen': true});
    router = AppRouter(session: session, push: NoopPushService());
  });

  tearDown(() {
    router.dispose();
    session.dispose();
  });

  String location() =>
      router.router.routerDelegate.currentConfiguration.uri.path;

  Future<L10n> pumpApp(
    WidgetTester tester, {
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    session.debugSetUser(
      const User(id: 'u-1', email: 'amina@shop.dz', firstName: 'Amina'),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionViewModel>.value(value: session),
          Provider<DashboardRepository>(
            create: (_) => FakeDashboardRepository(),
          ),
          Provider<PageRepository>(create: (_) => FakePageRepository()),
          Provider<AgentRepository>(create: (_) => FakeAgentRepository()),
          // Home's Produits card is a real destination now, so the route it
          // opens has to be able to build inside this host.
          Provider<ProductRepository>(create: (_) => FakeProductRepository()),
          Provider<CatalogueRepository>(
            create: (_) => FakeCatalogueRepository(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router.router,
          locale: locale,
          theme: AppTheme.build(locale),
          supportedLocales: AppLanguage.values.map((l) => l.locale),
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => ScreenInitializer(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return L10n.delegate.load(locale);
  }

  testWidgets('carries the five destinations of §16', (tester) async {
    final l10n = await pumpApp(tester);

    expect(location(), Routes.home);
    for (final label in [
      l10n.navHome,
      l10n.navQueue,
      l10n.navInbox,
      l10n.navStock,
      l10n.navOrders,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('a tab changes the route without stacking on the last',
      (tester) async {
    final l10n = await pumpApp(tester);

    await tester.tap(find.text(l10n.navStock));
    await tester.pumpAndSettle();
    expect(location(), Routes.stock);

    await tester.tap(find.text(l10n.navQueue));
    await tester.pumpAndSettle();
    expect(location(), Routes.queue);

    // `go`, not `push` — so there is nothing stacked to pop back through.
    // This is exactly what made back exit the app before (brief §21.7).
    expect(tester.takeException(), isNull);
  });

  testWidgets('only the current destination is lit', (tester) async {
    final l10n = await pumpApp(tester);

    // Scoped to the nav bar. The placeholder screens print their own title
    // from the same `l10n` key as the tab that opens them — `navStock` is
    // "STOCK" in both places — so an unscoped `find.text` matches twice the
    // moment that tab is the active one.
    Color tintOf(String label) => tester
        .widget<Text>(
          find.descendant(
            of: find.byType(AppBottomNav),
            matching: find.text(label),
          ),
        )
        .style!
        .color!;

    expect(tintOf(l10n.navHome), AppColors.textPrimary);
    expect(tintOf(l10n.navStock), AppColors.textMuted);

    await tester.tap(find.text(l10n.navStock));
    await tester.pumpAndSettle();

    expect(tintOf(l10n.navStock), AppColors.textPrimary);
    expect(tintOf(l10n.navHome), AppColors.textMuted);
  });

  testWidgets('the indicator bar sits above the active item only',
      (tester) async {
    await pumpApp(tester);

    // Kept in the tree on every item so the icons do not shift by two pixels
    // when the tab changes — only its opacity moves.
    final bars = tester.widgetList<Opacity>(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.byType(Opacity),
      ),
    );
    expect(bars.length, 5);
    expect(bars.where((o) => o.opacity == 1).length, 1);
  });

  group('home never routes into the tutorial', () {
    // Its steps are a first-run walkthrough — wizard chrome, a step counter, a
    // footer that advances. Reaching one from home would drop a merchant who
    // has already finished it back into the middle of it. The standalone
    // creation screens are not built, so these say so instead.
    Future<L10n> pumpTall(WidgetTester tester) async {
      final l10n = await pumpApp(tester);
      // The frame is 1600 long; a phone-height view only builds as far as
      // Aperçu, and Actions rapides sits below it.
      tester.view.physicalSize = const Size(411, 2400);
      await tester.pumpAndSettle();
      return l10n;
    }

    for (final label in ['connect', 'agents']) {
      testWidgets('the $label quick action does not', (tester) async {
        final l10n = await pumpTall(tester);
        final title = switch (label) {
          'connect' => l10n.homeActionConnectTitle,
          'products' => l10n.homeActionProductsTitle,
          _ => l10n.homeActionAgentsTitle,
        };

        // Scoped to the card: `Démarrer` names the same steps, so the bare
        // string matches twice.
        await tester.tap(
          find.descendant(
            of: find.byType(ActionCard),
            matching: find.text(title),
          ),
        );
        await tester.pumpAndSettle();

        expect(location(), Routes.home);
        expect(location().startsWith(Routes.tutorial), isFalse);
        // It says so rather than doing nothing, which reads as a broken tap.
        expect(find.byType(SnackBar), findsOneWidget);
      });
    }

    testWidgets('the products quick action goes to the catalogue, not to T3',
        (tester) async {
      final l10n = await pumpTall(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(ActionCard),
          matching: find.text(l10n.homeActionProductsTitle),
        ),
      );
      await tester.pumpAndSettle();

      // `17 — Produits` exists, so this card is a real destination. The rule
      // this group exists for still holds — and holds better: the standalone
      // screen is *why* the card does not have to reach the tutorial's own
      // product step.
      expect(location(), Routes.products);
      expect(location().startsWith(Routes.tutorial), isFalse);
    });

    testWidgets('nor does the no-page section', (tester) async {
      final l10n = await pumpTall(tester);

      await tester.tap(find.text(l10n.homeNoPageTitle));
      await tester.pumpAndSettle();

      expect(location(), Routes.home);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  testWidgets('the bar clears the system gesture inset', (tester) async {
    // A handset with a gesture bar reports a bottom inset; the frame's own 20
    // of padding must not stack on top of it.
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    tester.view.padding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);

    final l10n = await pumpApp(tester);

    final label = tester.getBottomLeft(find.text(l10n.navHome)).dy;
    expect(
      914 - label,
      greaterThanOrEqualTo(48),
      reason: 'the labels sit above the gesture bar, not under it',
    );
  });
}

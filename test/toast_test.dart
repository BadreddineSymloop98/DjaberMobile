import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// The success toast, driven through the real `T3` rather than by calling
/// [AppToast] directly.
///
/// Calling the helper proves only that a SnackBar can be built. What matters is
/// the pair of decisions behind it (2026-09-10): a **write that succeeds**
/// confirms with a toast, and a **write that fails** does not — its message
/// stays in the inline line where the merchant can still read it while they
/// fix the field. So every test here goes through the screen, and half of them
/// assert the absence of a toast.
void main() {
  late SessionViewModel session;
  late PrefsStorage prefs;
  late StockModeViewModel stockMode;
  late AppRouter router;

  const user = User(
    id: 'u-1',
    email: 'zakaria@djaber.test',
    firstName: 'Zakaria',
    lastName: 'Amrani',
  );

  var booted = false;

  Future<void> boot() async {
    session = await sessionForTest();
    prefs = await PrefsStorage.load();
    // `T3` is only reachable while the tutorial is owed: the router sends a
    // merchant who has finished it home from any tutorial path.
    await prefs.setTutorialPending(true);
    stockMode = StockModeViewModel(prefs: prefs);
    router = AppRouter(session: session, push: NoopPushService());
    session.debugSetUser(user);
    booted = true;
  }

  tearDown(() {
    // The last test drives AppToast directly and boots no app, so there is
    // nothing to tear down — and disposing a router twice throws.
    if (!booted) return;
    booted = false;
    router.dispose();
    session.dispose();
  });

  Future<L10n> pumpApp(
    WidgetTester tester, {
    required ProductRepository products,
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionViewModel>.value(value: session),
          Provider<PrefsStorage>.value(value: prefs),
          ChangeNotifierProvider<StockModeViewModel>.value(value: stockMode),
          Provider<ProductRepository>.value(value: products),
          Provider<PageRepository>(create: (_) => FakePageRepository()),
          Provider<AgentRepository>(create: (_) => FakeAgentRepository()),
          Provider<DashboardRepository>(
            create: (_) => FakeDashboardRepository(),
          ),
          ChangeNotifierProvider<TutorialViewModel>(
            create: (_) => TutorialViewModel(),
          ),
        ],
        // `MediaQuery.fromView` sits **above** `MaterialApp`, mirroring
        // `app.dart` and `authHost`. The theme is built in `MaterialApp`'s own
        // constructor, before anything in `MaterialApp.builder` runs, so
        // without this it sizes every control against a zero-width screen and
        // the footer button lays out at the wrong height.
        //
        // This cost real time here. `Screen` is static, so the defect showed
        // up only in whichever test ran *first* in the process — that one's
        // tap on « Créer le produit » silently missed, no request was sent,
        // and the failure read as "the toast never appeared". Exactly the trap
        // §22.6 records; this suite is the third place to hit it.
        child: MediaQuery.fromView(
          view: WidgetsBinding.instance.platformDispatcher.views.first,
          child: Builder(
            builder: (context) {
              Screen.update(MediaQuery.of(context));
              return MaterialApp.router(
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
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return L10n.delegate.load(locale);
  }

  /// Fills `T3` with a product the client-side validators accept, so what the
  /// test exercises is the response handling and not the form rules.
  Future<void> fillProduct(WidgetTester tester, L10n l10n) async {
    router.router.go(Routes.tutorialProduct);
    await tester.pumpAndSettle();

    // By index, not by label: `AppTextField` draws its label in a `RichText`
    // (it appends the required asterisk as a span), so `find.text` cannot
    // reach it and the label is a sibling of the field rather than an
    // ancestor. The order is the frame's, pinned at
    // tutorial_product_screen.dart:116 — name, SKU, description, cost, selling,
    // quantity. Description is left empty on purpose: it is the one optional
    // field, so filling it would hide a regression that made it required.
    Future<void> type(int index, String value) async {
      await tester.enterText(find.byType(TextField).at(index), value);
      await tester.pump();
    }

    await type(0, 'Robe satin — Noir — M');
    await type(1, 'PRD-0001');
    await type(3, '1200');
    await type(4, '2400');
    await type(5, '12');
  }

  testWidgets('a product that saves confirms with a toast', (tester) async {
    await boot();
    final l10n = await pumpApp(tester, products: FakeProductRepository());
    await fillProduct(tester, l10n);

    expect(find.byType(SnackBar), findsNothing, reason: 'not before the write');

    await tester.ensureVisible(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(l10n.toastProductCreated), findsOneWidget);
  });

  testWidgets('the toast outlives the navigation that follows it — it is read '
      'on the step after the one that raised it', (tester) async {
    await boot();
    final l10n = await pumpApp(tester, products: FakeProductRepository());
    await fillProduct(tester, l10n);

    await tester.ensureVisible(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    // Already moved on, and the confirmation is still up.
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      Routes.tutorialAgent,
    );
    expect(find.text(l10n.toastProductCreated), findsOneWidget);
  });

  testWidgets('a product that is refused raises no toast — the message belongs '
      'in the inline line, which does not disappear on a timer', (tester) async {
    await boot();
    final l10n = await pumpApp(
      tester,
      products: FakeProductRepository(fails: true),
    );
    await fillProduct(tester, l10n);

    await tester.ensureVisible(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    // Still on the step, with the backend's reason on screen.
    expect(
      router.router.routerDelegate.currentConfiguration.uri.path,
      Routes.tutorialProduct,
    );
    expect(find.text('SKU already exists'), findsOneWidget);
  });

  testWidgets('a form that fails its own validation raises no toast either',
      (tester) async {
    await boot();
    final l10n = await pumpApp(tester, products: FakeProductRepository());

    router.router.go(Routes.tutorialProduct);
    await tester.pumpAndSettle();

    // Submitted empty — the request is never sent, so there is nothing to
    // confirm and nothing to apologise for beyond the field errors.
    await tester.ensureVisible(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });

testWidgets('a server field error lands on the control it names, not just '
      'in the line above the button', (tester) async {
    await boot();
    // The real 400 for a zero quantity, captured 2026-09-10. The server names
    // the input; before the contract it named none, and the merchant had to
    // guess which of six fields the summary meant.
    final l10n = await pumpApp(
      tester,
      products: FakeProductRepository(
        fails: true,
        error: const ValidationException(
          'Certains champs sont invalides. Veuillez vérifier le formulaire.',
          statusCode: 400,
          code: 'VALIDATION_FAILED',
          fields: [
            ApiFieldError(
              field: 'sku',
              code: 'PRODUCT_SKU_ALREADY_EXISTS',
              message: 'Cette référence est déjà utilisée.',
            ),
          ],
        ),
      ),
    );
    await fillProduct(tester, l10n);

    await tester.ensureVisible(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    // On the field…
    expect(find.text('Cette référence est déjà utilisée.'), findsOneWidget);
    // …and the contract's summary above the button.
    expect(
      find.text('Certains champs sont invalides. Veuillez vérifier le formulaire.'),
      findsOneWidget,
    );
    // Still no toast: a failure stays put where the merchant can read it.
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('the confirmation is localised', (tester) async {
    await boot();
    final l10n = await pumpApp(
      tester,
      products: FakeProductRepository(),
      locale: const Locale('ar'),
    );
    await fillProduct(tester, l10n);

    await tester.ensureVisible(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.toastProductCreated), findsOneWidget);
    // Guards against a literal creeping into the call site.
    expect(l10n.toastProductCreated, matches(RegExp(r'[؀-ۿ]')));
  });

  testWidgets('AppToast is inert without a ScaffoldMessenger, so a '
      'confirmation cannot be what makes a screen untestable', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(() => AppToast.success(captured, 'anything'), returnsNormally);
  });
}

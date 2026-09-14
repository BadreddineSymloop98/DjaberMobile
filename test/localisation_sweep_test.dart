import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/notification_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// Every screen from the splash to home, in all three languages.
///
/// The copy has been in the ARBs for weeks and the app was pinned to French,
/// so **nothing had ever rendered these screens in Arabic or English**. That
/// is not a theoretical risk: the drawer's Arabic header overflowed by 14px
/// (§24.6) and was found exactly this way — by rendering it, not by reading
/// it. Arabic is the harder case of the two, because Changa's metrics differ
/// from Geist's and the whole layout mirrors.
///
/// The assertion is deliberately blunt — no exception during layout — because
/// that is what catches a `RenderFlex overflowed` and a missing localisation
/// alike. 320×640 is the floor this market actually ships on (`Screen.isSmall`
/// treats anything under 360 as small), so it is where a longer translation
/// breaks first.
void main() {
  late SessionViewModel session;
  late PrefsStorage prefs;
  late StockModeViewModel stockMode;
  late AppRouter router;

  const merchant = User(
    id: 'u-1',
    email: 'zakaria@djaber.test',
    firstName: 'Zakaria',
    lastName: 'Amrani',
    plan: 'individual',
    creditsUsed: 0,
    creditsLimit: 500,
  );

  setUp(() async {
    // Signed OUT by default: `sessionForTest` seeds a token, and `restore()`
    // would sign the merchant in — at which point the redirect quite correctly
    // sends them away from /login and /signup, and the sweep silently tests
    // home instead. `prepare` signs in only the screens that need it.
    session = await sessionForTest(token: null);
    prefs = await PrefsStorage.load();
    stockMode = StockModeViewModel(prefs: prefs);
    router = AppRouter(session: session, push: NoopPushService());
  });

  tearDown(() {
    router.dispose();
    session.dispose();
  });

  Future<void> pumpAt(
    WidgetTester tester,
    String route, {
    required Locale locale,
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionViewModel>.value(value: session),
          Provider<PrefsStorage>.value(value: prefs),
          ChangeNotifierProvider<StockModeViewModel>.value(value: stockMode),
          Provider<ProductRepository>(create: (_) => FakeProductRepository()),
          Provider<PageRepository>(create: (_) => FakePageRepository()),
          Provider<AgentRepository>(create: (_) => FakeAgentRepository()),
          Provider<DashboardRepository>(
            create: (_) => FakeDashboardRepository(),
          ),
          Provider<NotificationRepository>(
            create: (_) => FakeNotificationRepository(),
          ),
          ChangeNotifierProvider<TutorialViewModel>(
            create: (_) => TutorialViewModel(),
          ),
        ],
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

    // The splash holds for its own animation floor before handing over, so
    // navigating during it would be overtaken by its redirect a moment later
    // and land somewhere else. Let it finish first.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    router.router.go(route);
    await tester.pumpAndSettle();
  }

  /// One string per screen that must come from the right dictionary.
  ///
  /// "No exception" proves the layout survives; it says nothing about whether
  /// the words are the right ones. A French title on an Arabic screen lays out
  /// perfectly.
  final headline = <String, String Function(L10n)>{
    'onboarding': (l) => l.onboardingStockTitle,
    'login': (l) => l.authLoginTitle,
    'signup': (l) => l.authSignupTitle,
    'forgot password': (l) => l.authForgotTitle,
    'T2 mode': (l) => l.tutorialModeTitle,
    'T3 product': (l) => l.tutorialProductTitle,
    'T4 agent': (l) => l.tutorialAgentTitle,
    'T5 connect': (l) => l.tutorialConnectTitle,
    // The *pending* title, not the live one. No page is connected in this
    // sweep, and `T6` reads its own state rather than always congratulating
    // (§23.7): with nothing linked it drops "your agent is live" for "you are
    // nearly there". Asserting the live title here would have been asserting a
    // lie the screen deliberately refuses to tell.
    'T6 ready': (l) => l.tutorialReadyTitlePending,
    'home': (l) => l.homeSnapshot,
  };

  /// What has to be true for a route to be the screen you actually get.
  ///
  /// Learned the hard way: the first version of this sweep signed the merchant
  /// in for every case, so the redirect sent `/login`, `/signup` and
  /// `/forgot-password` straight to home — and the blunt no-exception check
  /// passed, on home, four times over. A sweep that asserts nothing about
  /// *which* screen it is looking at is worse than no sweep, because it reads
  /// as coverage.
  Future<void> prepare(String screen) async {
    final isAuth = screen == 'login' ||
        screen == 'signup' ||
        screen == 'forgot password';
    final isTutorial = screen.startsWith('T');

    if (screen == 'onboarding') {
      // The install intro shows only before it has been seen.
      await prefs.setOnboardingSeen(false);
      return;
    }

    await prefs.setOnboardingSeen(true);
    if (isAuth) return; // signed out, which is the default here

    session.debugSetUser(merchant);
    if (isTutorial) {
      // The redirect holds a merchant on /tutorial while this is set, and
      // lets any step through once they are inside it.
      await prefs.setTutorialPending(true);
      await session.rememberTutorialStep(Routes.tutorialReady);
    }
  }

  /// The flow, in the order a merchant walks it.
  const flow = <String, String>{
    'onboarding': Routes.onboarding,
    'login': Routes.login,
    'signup': Routes.signup,
    'forgot password': Routes.forgotPassword,
    'T1a intro': Routes.tutorial,
    'T2 mode': Routes.tutorialMode,
    'T3 product': Routes.tutorialProduct,
    'T4 agent': Routes.tutorialAgent,
    'T5 connect': Routes.tutorialConnect,
    'T6 ready': Routes.tutorialReady,
    'home': Routes.home,
  };

  // 320 is where a longer translation breaks first; 411 is the frames' own.
  const sizes = <String, Size>{
    '320x640': Size(320, 640),
    '411x914': Size(411, 914),
  };

  for (final language in [AppLanguage.arabic, AppLanguage.english]) {
    group(language.code, () {
      for (final size in sizes.entries) {
        for (final screen in flow.entries) {
          testWidgets('${screen.key} lays out at ${size.key}', (tester) async {
            await prepare(screen.key);

            await pumpAt(
              tester,
              screen.value,
              locale: language.locale,
              size: size.value,
            );

            expect(
              tester.takeException(),
              isNull,
              reason: '${screen.key} in ${language.code} at ${size.key}',
            );

            // The screen under test is the one on screen.
            expect(
              router.router.routerDelegate.currentConfiguration.uri.path,
              screen.value,
              reason: 'the redirect served a different screen',
            );

            // The words come from this language's dictionary, and the French
            // ones are absent — a French title lays out perfectly, so the
            // layout check above cannot see it.
            final want = headline[screen.key];
            if (want != null) {
              final mine = await L10n.delegate.load(language.locale);
              final french = await L10n.delegate.load(const Locale('fr'));
              expect(
                find.text(want(mine)),
                findsWidgets,
                reason: '${screen.key} should be in ${language.code}',
              );
              if (want(french) != want(mine)) {
                expect(
                  find.text(want(french)),
                  findsNothing,
                  reason: '${screen.key} still shows French',
                );
              }
            }

            // Arabic mirrors the whole subtree; nothing else should.
            //
            // Read from the app's own Directionality widget, not from the
            // MaterialApp element — `Directionality.of` looks for an
            // *ancestor*, and MaterialApp is what provides it, so asking there
            // throws "No Directionality widget found".
            expect(
              tester
                  .widget<Directionality>(find.byType(Directionality).first)
                  .textDirection,
              language.isRtl ? TextDirection.rtl : TextDirection.ltr,
              reason: '${screen.key} direction in ${language.code}',
            );
          });
        }
      }
    });
  }
}

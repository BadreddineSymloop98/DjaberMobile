import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/models/conversation.dart';
import 'package:djaber_mobile/data/models/dashboard_stats.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/notification_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/home/home_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_icon.dart';
import 'package:djaber_mobile/presentation/widgets/checklist_row.dart';
import 'package:djaber_mobile/presentation/widgets/djaber_logo.dart';
import 'package:djaber_mobile/presentation/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// `09 — Accueil`, against repositories that answer from memory.
///
/// The screen's whole claim is that **nothing on it is sample data**, so every
/// figure asserted here is traced back to the fake that produced it.
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  const amina = User(
    id: 'u-1',
    email: 'amina@shop.dz',
    firstName: 'Amina',
    lastName: 'Benali',
  );

  ConnectedPage page(String id, String name, {bool instagram = false}) =>
      ConnectedPage(
        id: id,
        platform: instagram ? PagePlatform.instagram : PagePlatform.facebook,
        pageId: 'meta-$id',
        pageName: name,
        createdAt: DateTime(2026, 8, 12),
      );

  Conversation thread(
    String id, {
    required String pageId,
    required bool paused,
    String who = 'Amina B.',
    String text = 'wach kayen promo',
    Duration ago = const Duration(minutes: 2),
  }) =>
      Conversation(
        id: id,
        pageId: pageId,
        senderName: who,
        aiPaused: paused,
        lastMessage: text,
        lastMessageAt: DateTime.now().subtract(ago),
      );

  Future<L10n> pump(
    WidgetTester tester, {
    DashboardRepository? dashboard,
    PageRepository? pages,
    AgentRepository? agents,
    User? user = const User(
      id: 'u-1',
      email: 'amina@shop.dz',
      firstName: 'Amina',
    ),
    Size size = const Size(390, 844),
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    if (user != null) session.debugSetUser(user);

    await tester.pumpWidget(
      authHost(
        const HomeScreen(),
        session,
        locale: locale,
        extra: [
          Provider<DashboardRepository>.value(
            value: dashboard ?? FakeDashboardRepository(),
          ),
          Provider<PageRepository>.value(value: pages ?? FakePageRepository()),
          Provider<AgentRepository>.value(
            value: agents ?? FakeAgentRepository(),
          ),
          // The menu button opens the drawer, which reads its notification
          // badge from this.
          Provider<NotificationRepository>(
            create: (_) => FakeNotificationRepository(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return L10n.delegate.load(locale);
  }

  group('the greeting', () {
    testWidgets('names the merchant, and follows the time of day',
        (tester) async {
      final l10n = await pump(tester, user: amina);

      final hour = DateTime.now().hour;
      final greeting = hour < 12
          ? l10n.homeGreetingMorning
          : hour < 18
              ? l10n.homeGreetingAfternoon
              : l10n.homeGreetingEvening;

      expect(find.text('$greeting, Amina'), findsOneWidget);
      expect(find.text(l10n.homeSnapshot), findsOneWidget);
    });

    testWidgets('falls back to the email when there is no first name',
        (tester) async {
      final l10n = await pump(
        tester,
        user: const User(id: 'u-2', email: 'boutique.oran@shop.dz'),
      );

      // A greeting ending in ", " reads as a bug.
      expect(
        find.textContaining('boutique.oran'),
        findsOneWidget,
        reason: 'the local part stands in for a missing first name',
      );
      expect(find.text(l10n.homeSnapshot), findsOneWidget);
    });

    testWidgets('renders without a user rather than throwing', (tester) async {
      // Reachable for one frame: the router redirects away from home when the
      // session ends, but the screen may build once before that lands.
      await pump(tester, user: null);
      expect(tester.takeException(), isNull);
    });
  });

  group('the credits pill', () {
    Color boltTint(WidgetTester tester) => tester
        .widget<AppIcon>(
          find.descendant(
            of: find.byType(CreditsPill),
            matching: find.byType(AppIcon),
          ),
        )
        .color;

    testWidgets('shows remaining over the limit, with an amber bolt',
        (tester) async {
      await pump(
        tester,
        user: const User(
          id: 'u-1',
          email: 'amina@shop.dz',
          firstName: 'Amina',
          creditsUsed: 1240,
          creditsLimit: 5000,
        ),
      );

      expect(find.byType(CreditsPill), findsOneWidget);
      expect(boltTint(tester), AppColors.accentStarred);
    });

    testWidgets('sits against the right edge, matching the menu button’s inset',
        (tester) async {
      await pump(
        tester,
        user: const User(
          id: 'u-1',
          email: 'amina@shop.dz',
          firstName: 'Amina',
          creditsUsed: 1240,
          creditsLimit: 5000,
        ),
      );

      final menuLeft = tester.getTopLeft(find.byType(MenuButton)).dx;
      final pillRight = tester.getTopRight(find.byType(CreditsPill)).dx;

      // The two things the header insets are a square button and a pill; they
      // read as a matched pair, so their edges match.
      expect(pillRight, closeTo(390 - menuLeft, 0.5));
      // And it is genuinely at the edge, not tucked in beside the wordmark.
      final logoRight = tester.getTopRight(find.byType(DjaberLogo)).dx;
      expect(pillRight, greaterThan(logoRight + 40));
    });

    testWidgets('turns alert when the allowance is spent', (tester) async {
      await pump(
        tester,
        user: const User(
          id: 'u-1',
          email: 'amina@shop.dz',
          firstName: 'Amina',
          creditsUsed: 5000,
          creditsLimit: 5000,
        ),
      );

      // Exhausted outranks the amber: when credits run out the agent stops
      // replying, which is the one header state worth shouting about.
      expect(boltTint(tester), AppColors.accentAlert);
    });

    testWidgets('stays off while credits are unknown', (tester) async {
      // Signing in returns no credits; only `/profile` does. An empty pill
      // would read as an exhausted allowance.
      await pump(tester);
      expect(find.byType(CreditsPill), findsNothing);
    });
  });

  group('the figures are the backend’s', () {
    testWidgets('products, low stock, revenue and pages all come from the API',
        (tester) async {
      final l10n = await pump(
        tester,
        dashboard: FakeDashboardRepository(
          stats0: const DashboardStats(
            totalProducts: 128,
            lowStockProducts: 3,
            totalStockValue: 1240000,
          ),
          sales0: const SalesStats(totalSales: 24, totalRevenue: 96000),
          conversations: const {'p-1': [], 'p-2': []},
        ),
        pages: FakePageRepository(
          pages: [page('p-1', 'Boutique Amel'), page('p-2', 'Amel Cosmétiques')],
        ),
      );

      expect(find.text('128'), findsOneWidget); // products
      expect(find.text('2'), findsOneWidget); // connected pages
      expect(find.text(l10n.homeKpiLowStock(3).toUpperCase()), findsOneWidget);
      expect(find.text(l10n.homeKpiSales(24).toUpperCase()), findsOneWidget);

      // 1 240 000 DA is written the way the frame writes it.
      expect(find.text('1,24'), findsOneWidget);
      expect(find.text('M DA'), findsWidgets);
      // 96 000 DA → 96,0 K DA
      expect(find.text('96,0'), findsOneWidget);
    });

    testWidgets('a dead endpoint does not take the rest of the screen with it',
        (tester) async {
      await pump(
        tester,
        // Tall enough to build the whole screen: the frame is 1600 long, so a
        // phone-height view only builds as far as Aperçu and a `find` below
        // that would fail for being off-screen rather than absent.
        size: const Size(390, 2200),
        // Sales is down; stock and pages are fine.
        dashboard: FakeDashboardRepository(
          stats0: const DashboardStats(totalProducts: 7),
          salesFails: true,
          conversations: const {'p-1': []},
        ),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
      );

      expect(tester.takeException(), isNull);
      // The figures that did arrive are still on screen.
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Boutique Amel'), findsWidgets);
    });
  });

  group('À traiter', () {
    testWidgets('lists only the conversations the AI handed over',
        (tester) async {
      await pump(
        tester,
        dashboard: FakeDashboardRepository(
          conversations: {
            'p-1': [
              thread('c-1', pageId: 'p-1', paused: true, who: 'Amina B.'),
              // The agent is coping with this one — not the merchant's problem.
              thread('c-2', pageId: 'p-1', paused: false, who: 'Sofiane K.'),
            ],
          },
        ),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
      );

      expect(find.text('Amina B.'), findsOneWidget);
      expect(find.text('Sofiane K.'), findsNothing);
    });

    testWidgets('fans out across every connected page', (tester) async {
      final dashboard = FakeDashboardRepository(
        conversations: {
          'p-1': [thread('c-1', pageId: 'p-1', paused: true, who: 'Amina B.')],
          'p-2': [thread('c-2', pageId: 'p-2', paused: true, who: 'Yacine M.')],
        },
      );

      await pump(
        tester,
        dashboard: dashboard,
        pages: FakePageRepository(
          pages: [page('p-1', 'Boutique Amel'), page('p-2', 'Amel Cosmétiques')],
        ),
      );

      // No endpoint lists conversations across Pages, so the queue must ask
      // each one — a merchant with two Pages must not see only the first.
      expect(dashboard.asked, ['p-1', 'p-2']);
      expect(find.text('Amina B.'), findsOneWidget);
      expect(find.text('Yacine M.'), findsOneWidget);
    });

    testWidgets('one unreachable page does not hide the other’s escalations',
        (tester) async {
      await pump(
        tester,
        dashboard: FakeDashboardRepository(
          // `p-2` is absent from the map, so the fake fails for it.
          conversations: {
            'p-1': [thread('c-1', pageId: 'p-1', paused: true, who: 'Amina B.')],
          },
        ),
        pages: FakePageRepository(
          pages: [page('p-1', 'Boutique Amel'), page('p-2', 'Amel Cosmétiques')],
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Amina B.'), findsOneWidget);
    });

    testWidgets('says nothing is waiting rather than showing an empty box',
        (tester) async {
      final l10n = await pump(
        tester,
        dashboard: FakeDashboardRepository(conversations: const {'p-1': []}),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
      );

      expect(find.text(l10n.homeQueueEmpty), findsOneWidget);
      expect(find.byType(EscalationCard), findsNothing);
    });
  });

  group('with no page connected', () {
    testWidgets('a section above À traiter says so, and offers the step',
        (tester) async {
      final l10n = await pump(tester);

      expect(find.text(l10n.homeNoPageTitle), findsOneWidget);
      expect(find.text(l10n.homeNoPageBody), findsOneWidget);

      // Above, not below: it explains the silence in the section that follows.
      final banner = tester.getTopLeft(find.text(l10n.homeNoPageTitle)).dy;
      final queue = tester.getTopLeft(find.text(l10n.homeQueue.toUpperCase())).dy;
      expect(banner, lessThan(queue));

      // And the queue's own emptiness is explained by the same fact, not by
      // the generic "nothing waiting".
      expect(find.text(l10n.homeQueueNoPage), findsOneWidget);
      expect(find.text(l10n.homeQueueEmpty), findsNothing);
    });

    testWidgets('it is gone once a page is connected', (tester) async {
      final l10n = await pump(
        tester,
        dashboard: FakeDashboardRepository(conversations: const {'p-1': []}),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
      );

      expect(find.text(l10n.homeNoPageTitle), findsNothing);
      expect(find.text(l10n.homeQueueNoPage), findsNothing);
    });
  });

  group('Démarrer', () {
    testWidgets('ticks from what the merchant actually has', (tester) async {
      await pump(
        tester,
        size: const Size(390, 2200),
        dashboard: FakeDashboardRepository(
          stats0: const DashboardStats(totalProducts: 4),
          conversations: const {'p-1': []},
        ),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
        agents: FakeAgentRepository(agents: const []),
      );

      final rows =
          tester.widgetList<ChecklistRow>(find.byType(ChecklistRow)).toList();
      expect(rows.length, 4);
      expect(rows[0].done, isTrue, reason: 'a page is connected');
      expect(rows[1].done, isTrue, reason: '4 products exist');
      expect(rows[2].done, isFalse, reason: 'no agent yet');
      expect(rows[3].done, isFalse, reason: 'no sale yet');
    });

    testWidgets('nothing is ticked for a merchant who has nothing',
        (tester) async {
      await pump(tester);

      final rows =
          tester.widgetList<ChecklistRow>(find.byType(ChecklistRow)).toList();
      expect(rows.every((r) => !r.done), isTrue);
    });
  });

  group('Vos pages', () {
    testWidgets('lists each page with its network and its state',
        (tester) async {
      final l10n = await pump(
        tester,
        size: const Size(390, 2200),
        dashboard: FakeDashboardRepository(conversations: const {'p-1': []}),
        pages: FakePageRepository(
          pages: [page('p-1', 'Amel Cosmétiques', instagram: true)],
        ),
      );

      expect(find.text('Amel Cosmétiques'), findsWidgets);
      expect(find.text(l10n.homePageActive.toUpperCase()), findsWidgets);
      expect(
        find.textContaining(l10n.platformInstagram.toUpperCase()),
        findsOneWidget,
      );
    });
  });

  group('sign out', () {
    testWidgets('is reachable from the menu button', (tester) async {
      final l10n = await pump(tester);

      // Now via the real drawer (`09a — Menu`), which took this over from
      // the stand-in sheet. The frame draws no sign-out, so that row is a
      // deliberate divergence — see `menu_drawer.dart`. This test passing
      // unchanged across the swap is the evidence the path survived it.
      expect(find.text(l10n.menuSignOut), findsNothing);
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      expect(find.text(l10n.menuSignOut), findsOneWidget);
    });
  });

  for (final size in const [Size(320, 640), Size(360, 740), Size(411, 914)]) {
    testWidgets('renders without overflow at ${size.width.toInt()} wide',
        (tester) async {
      await pump(
        tester,
        size: size,
        dashboard: FakeDashboardRepository(
          stats0: const DashboardStats(
            totalProducts: 128,
            lowStockProducts: 3,
            totalStockValue: 1240000,
          ),
          sales0: const SalesStats(totalSales: 24, totalRevenue: 96000),
          conversations: {
            'p-1': [thread('c-1', pageId: 'p-1', paused: true)],
          },
        ),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
        agents: FakeAgentRepository(
          agents: const [Agent(id: 'a-1', name: 'Assistant')],
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('renders in ${locale.languageCode}', (tester) async {
      final l10n = await pump(
        tester,
        locale: locale,
        size: const Size(320, 640),
        dashboard: FakeDashboardRepository(conversations: const {'p-1': []}),
        pages: FakePageRepository(pages: [page('p-1', 'Boutique Amel')]),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(l10n.homeSnapshot), findsOneWidget);
    });
  }
}

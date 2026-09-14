import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/notification_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/home/menu_drawer.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_icon.dart';
import 'package:djaber_mobile/presentation/widgets/menu_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// `09a — Menu`, the tier-3 drawer.
///
/// Measured rather than eyeballed, following `visual_regression_test`: the
/// frame's numbers — 336 wide, rows 48 high, subrows 40, the 34 indent — are
/// what make it read as a list of equals with a subordinate group, and every
/// one of them has been silently wrong in this codebase at least once
/// (§23.9's KPI tile, §22.6's progress bar).
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  const zakaria = User(
    id: 'u-1',
    email: 'zakaria@djaber.test',
    firstName: 'Zakaria',
    lastName: 'Amrani',
    plan: 'individual',
    creditsUsed: 0,
    creditsLimit: 500,
  );

  Future<L10n> pump(
    WidgetTester tester, {
    User? user = zakaria,
    Locale locale = const Locale('fr'),
    Size size = const Size(390, 844),
    int? connectedPages = 2,
    int unread = 0,
    bool unreadFails = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    if (user != null) session.debugSetUser(user);
    await tester.pumpWidget(
      authHost(
        MenuDrawer(connectedPages: connectedPages),
        session,
        locale: locale,
        extra: [
          Provider<NotificationRepository>.value(
            value: FakeNotificationRepository(
              count: unread,
              fails: unreadFails,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return L10n.delegate.load(locale);
  }

  Color iconColour(WidgetTester tester, String label) {
    final row = find.ancestor(
      of: find.text(label),
      matching: find.byType(Row),
    );
    final icon = tester.widget<AppIcon>(
      find.descendant(of: row.first, matching: find.byType(AppIcon)).first,
    );
    return icon.color;
  }

  group('what the drawer contains', () {
    testWidgets('the eight rows the web sidebar has, in its order',
        (tester) async {
      final l10n = await pump(tester);

      for (final label in [
        l10n.menuOverview,
        l10n.menuInbox,
        l10n.menuSocial,
        l10n.menuServices,
        l10n.menuNotifications,
        l10n.menuAnalytics,
        l10n.menuReports,
        l10n.menuSettings,
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('Services is open, showing its three subrows', (tester) async {
      final l10n = await pump(tester);

      expect(find.text(l10n.menuProducts), findsOneWidget);
      expect(find.text(l10n.menuAgents), findsOneWidget);
      expect(find.text(l10n.menuCommercial), findsOneWidget);
      // The web ships Commercial `active: false` with a null href.
      expect(find.text(l10n.menuSoon.toUpperCase()), findsOneWidget);
    });

    testWidgets('Commercial is inert — the one row with no onTap at all',
        (tester) async {
      final l10n = await pump(tester);

      final subrow = tester.widget<MenuSubrow>(
        find.ancestor(
          of: find.text(l10n.menuCommercial),
          matching: find.byType(MenuSubrow),
        ),
      );
      expect(subrow.onTap, isNull);
    });
  });

  group('the frame\'s measurements', () {
    testWidgets('the drawer is 336 of the 390, leaving home visible behind it',
        (tester) async {
      await pump(tester);

      final width = tester.getSize(find.byType(MenuDrawer)).width;
      // MenuDrawer fills the route; the panel inside it is what is measured.
      final panel = tester.getSize(
        find.descendant(
          of: find.byType(MenuDrawer),
          matching: find.byType(Material),
        ).first,
      );
      expect(width, 390);
      expect(panel.width, moreOrLessEquals(336, epsilon: 1));
    });

    testWidgets('rows are 48 and subrows are 40, so the group reads as '
        'subordinate', (tester) async {
      final l10n = await pump(tester);

      expect(
        tester.getSize(find.ancestor(
          of: find.text(l10n.menuOverview),
          matching: find.byType(MenuRow),
        )).height,
        moreOrLessEquals(48, epsilon: 1),
      );
      expect(
        tester.getSize(find.ancestor(
          of: find.text(l10n.menuProducts),
          matching: find.byType(MenuSubrow),
        )).height,
        moreOrLessEquals(40, epsilon: 1),
      );
    });

    testWidgets('a subrow label is indented past its parent row label, which '
        'is the hierarchy and is meant to be seen', (tester) async {
      final l10n = await pump(tester);

      // Measured against the frame: the row pads 12 and its icon box is 24
      // with a 10 gap, so its label lands at 46; the subrow pads 34 with a 16
      // icon and the same gap, so its label lands at 60. The 14 between them
      // is the indent. I first assumed the two lined up and asserted that —
      // they do not, and the frame is right.
      expect(
        tester.getTopLeft(find.text(l10n.menuProducts)).dx -
            tester.getTopLeft(find.text(l10n.menuServices)).dx,
        moreOrLessEquals(14, epsilon: 1),
      );
    });
  });

  group('the Services disclosure', () {
    testWidgets('collapses and reopens, and the chevron follows',
        (tester) async {
      final l10n = await pump(tester);

      expect(find.text(l10n.menuProducts), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is AppIcon && w.paths == AppIcons.chevronDown,
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.menuServices));
      await tester.pumpAndSettle();

      expect(find.text(l10n.menuProducts), findsNothing);
      expect(find.text(l10n.menuAgents), findsNothing);
      expect(find.text(l10n.menuCommercial), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is AppIcon && w.paths == AppIcons.chevronDown,
        ),
        findsNothing,
      );

      await tester.tap(find.text(l10n.menuServices));
      await tester.pumpAndSettle();
      expect(find.text(l10n.menuProducts), findsOneWidget);
    });
  });

  group('icon colour follows the module, not the screen', () {
    testWidgets('every row takes the accent for what it IS, per §21.3',
        (tester) async {
      final l10n = await pump(tester);

      // catalogue amber · the AI signal/live · alerts red · inbound blue ·
      // people violet · tools and actions white.
      expect(iconColour(tester, l10n.menuProducts), AppColors.accentStarred);
      expect(iconColour(tester, l10n.menuAgents), AppColors.live);
      expect(iconColour(tester, l10n.menuNotifications), AppColors.accentAlert);
      expect(iconColour(tester, l10n.menuInbox), AppColors.accentInbound);
      expect(iconColour(tester, l10n.menuSocial), AppColors.accentClients);
      expect(iconColour(tester, l10n.menuSettings), AppColors.textPrimary);
      expect(iconColour(tester, l10n.menuOverview), AppColors.textPrimary);
      expect(iconColour(tester, l10n.menuServices), AppColors.textPrimary);
    });

    testWidgets('the inbox is inbound blue, not the AI green it used to be — '
        'that row is about the customer, not the agent', (tester) async {
      final l10n = await pump(tester);

      expect(iconColour(tester, l10n.menuInbox), AppColors.accentInbound);
      expect(iconColour(tester, l10n.menuInbox), isNot(AppColors.live));
    });

    testWidgets('sign-out is white, not the muted default — it is the one row '
        'that always works', (tester) async {
      final l10n = await pump(tester);

      // It had been left unset, which meant text/muted: in this drawer that is
      // the colour of the three rows a merchant cannot use.
      expect(iconColour(tester, l10n.menuSignOut), AppColors.textPrimary);
      expect(iconColour(tester, l10n.menuSignOut), isNot(AppColors.textMuted));
    });

    testWidgets('the accents are all distinct, which is what keeps the colour '
        'readable as meaning rather than decoration', (tester) async {
      final l10n = await pump(tester);

      final accents = [
        iconColour(tester, l10n.menuInbox),
        iconColour(tester, l10n.menuSocial),
        iconColour(tester, l10n.menuProducts),
        iconColour(tester, l10n.menuAgents),
        iconColour(tester, l10n.menuNotifications),
      ];
      expect(accents.toSet(), hasLength(accents.length));
    });

    testWidgets('Analyses and Rapports stay muted, because grey is how this '
        'drawer says "lives on the web"', (tester) async {
      final l10n = await pump(tester);

      expect(iconColour(tester, l10n.menuAnalytics), AppColors.textMuted);
      expect(iconColour(tester, l10n.menuReports), AppColors.textMuted);
    });
  });

  group('the plan box', () {
    testWidgets('shows the plan and the page count, which is what the web '
        'sidebar shows here', (tester) async {
      final l10n = await pump(tester, connectedPages: 2);

      // Verified against the live app on 2026-09-10: `Votre plan —
      // individual`, `Pages — 0 / 10`.
      expect(find.text('Individual'), findsOneWidget);
      expect(find.text(l10n.menuPlan.toUpperCase()), findsOneWidget);
      expect(find.text('2 / 10'), findsOneWidget);
      expect(find.text(l10n.menuPages.toUpperCase()), findsOneWidget);
    });

    testWidgets('carries no credits — the header pill owns those, and it '
        'reads remaining while this box read used', (tester) async {
      await pump(tester);

      // The contradiction this replaced: 500 / 500 in the header above
      // 0 / 500 here, for one account at one moment.
      expect(find.textContaining('500'), findsNothing);
    });

    testWidgets('the page cap is the hardcoded 10 the web uses, not the '
        'plan limit — Individual is one page per §21.1', (tester) async {
      await pump(tester, connectedPages: 0);

      // layout.tsx:492 is `{pages.length} / 10` regardless of plan. Ported
      // as-is; wrong on both clients, and pinned here so the divergence is
      // deliberate rather than forgotten.
      expect(find.text('0 / 10'), findsOneWidget);
    });

    testWidgets('none of the frame figures are hardcoded', (tester) async {
      await pump(tester);

      // The four the Figma file disagrees on (§23.10).
      expect(find.text('Pro'), findsNothing);
      expect(find.text('3 760 / 5 000'), findsNothing);
      expect(find.text('2/∞'), findsNothing);
    });

    testWidgets('the page row is absent, not zero, when the count is unknown',
        (tester) async {
      final l10n = await pump(tester, connectedPages: null);

      // `0 / 10` on a merchant who has two pages would be a lie, so the row
      // waits — the same reasoning that keeps home's credits pill off.
      expect(find.text(l10n.menuPages.toUpperCase()), findsNothing);
      expect(find.text('Individual'), findsOneWidget);
    });

    testWidgets('an unknown plan is a dash, not a guess', (tester) async {
      final l10n = await pump(
        tester,
        user: const User(id: 'u-1', email: 'z@djaber.test'),
      );

      expect(find.text(l10n.menuPlanUnknown), findsOneWidget);
    });
  });

// The web's rule, verbatim from `layout.tsx:355`:
  //
  //   const badge = item.id === 'social-media' ? pages.length
  //               : (item.id === 'notifications' && unreadCount > 0) ? unreadCount
  //               : undefined;
  //
  // Note the asymmetry — pages has no `> 0` guard and notifications does.
  // It looks like an oversight and is not: "0 pages" belongs on the row that
  // lets you fix it, while a standing `0` beside a bell reads as a broken
  // badge. These tests exist mostly so a later pass does not "tidy" the two
  // into agreeing.
  group('the row badges', () {
    /// The count as rendered inside one row, or null when there is none.
    String? badgeOf(WidgetTester tester, String label) {
      final row = tester.widget<MenuRow>(find.ancestor(
        of: find.text(label),
        matching: find.byType(MenuRow),
      ));
      return row.count;
    }

    testWidgets('Réseaux sociaux carries the connected page count',
        (tester) async {
      final l10n = await pump(tester, connectedPages: 2);

      expect(badgeOf(tester, l10n.menuSocial), '2');
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('and shows it at zero, unlike notifications', (tester) async {
      final l10n = await pump(tester, connectedPages: 0, unread: 0);

      expect(badgeOf(tester, l10n.menuSocial), '0');
      expect(badgeOf(tester, l10n.menuNotifications), isNull);
    });

    testWidgets('the page badge is absent when the count is unknown',
        (tester) async {
      final l10n = await pump(tester, connectedPages: null);

      expect(badgeOf(tester, l10n.menuSocial), isNull);
    });

    testWidgets('Notifications carries the unread count once it answers',
        (tester) async {
      final l10n = await pump(tester, unread: 3);

      expect(badgeOf(tester, l10n.menuNotifications), '3');
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('a failed count leaves the badge absent, not zero',
        (tester) async {
      final l10n = await pump(tester, unread: 7, unreadFails: true);

      // "We could not ask" is not the same claim as "nothing is waiting".
      expect(badgeOf(tester, l10n.menuNotifications), isNull);
      // And it fails quietly — the drawer was opened to navigate.
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text(l10n.menuSettings), findsOneWidget);
    });

    testWidgets('no other row carries a badge', (tester) async {
      final l10n = await pump(tester, connectedPages: 2, unread: 3);

      for (final label in [
        l10n.menuOverview,
        l10n.menuInbox,
        l10n.menuServices,
        l10n.menuAnalytics,
        l10n.menuReports,
        l10n.menuSettings,
        l10n.menuSignOut,
      ]) {
        expect(badgeOf(tester, label), isNull, reason: label);
      }
    });
  });

  group('sign out', () {
    testWidgets('is in the drawer, which is a deliberate divergence — the '
        'frame draws no way out of a session', (tester) async {
      final l10n = await pump(tester);

      expect(find.text(l10n.menuSignOut), findsOneWidget);
      final row = tester.widget<MenuRow>(
        find.ancestor(
          of: find.text(l10n.menuSignOut),
          matching: find.byType(MenuRow),
        ),
      );
      expect(row.onTap, isNotNull);
    });
  });

  group('Arabic', () {
    testWidgets('mirrors the contents but not the disclosure chevron',
        (tester) async {
      final l10n = await pump(tester, locale: const Locale('ar'));

      // The icon leads on the right in Arabic, so the label's left edge is no
      // longer the row's left edge.
      final servicesRow = find.ancestor(
        of: find.text(l10n.menuServices),
        matching: find.byType(MenuRow),
      );
      final rowRight = tester.getTopRight(servicesRow).dx;
      final iconRight = tester
          .getTopRight(
            find.descendant(of: servicesRow, matching: find.byType(AppIcon))
                .first,
          )
          .dx;
      expect(
        iconRight,
        closeTo(rowRight, 20),
        reason: 'the leading icon should sit against the trailing edge',
      );

      // And the subrow indent flips with it: the same 14, now measured from
      // the right edge inwards.
      expect(
        tester.getTopRight(find.text(l10n.menuServices)).dx -
            tester.getTopRight(find.text(l10n.menuProducts)).dx,
        moreOrLessEquals(14, epsilon: 1),
      );
    });
  });
// The market is low-end Android and a 360dp width is the floor, not the
  // exception (`Screen.isSmall`). The drawer is the app's tallest stack of
  // fixed-height rows, so it is the most likely thing to overflow.
  for (final size in const [Size(320, 640), Size(360, 740), Size(411, 914)]) {
    testWidgets('fits ${size.width.toInt()}x${size.height.toInt()} without '
        'overflowing', (tester) async {
      final l10n = await pump(tester, size: size);

      // An overflow raises during layout and `takeException` surfaces it;
      // asserting on the widget being *found* would pass over a clipped one.
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.menuSettings), findsOneWidget);
      expect(find.text(l10n.menuSignOut), findsOneWidget);

      // Still 336 of a 320 screen would leave nothing behind it, so the panel
      // has to give way on the narrowest handsets rather than being cut off.
      final panel = tester.getSize(
        find.descendant(
          of: find.byType(MenuDrawer),
          matching: find.byType(Material),
        ).first,
      );
      expect(panel.width, lessThan(size.width));
    });
  }
}

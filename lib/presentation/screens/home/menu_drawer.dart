import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/djaber_logo.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/menu_row.dart';

/// `09a — Menu` (node `148:647`) — tier-3 navigation.
///
/// The web collapses its sidebar into a hamburger below `lg`
/// (`max-lg:-translate-x-full`, a `MenuIcon` button, a `bg-black/70` scrim),
/// so **the sidebar *is* the mobile menu** — this is a port of it, not an
/// invention. Every label and every glyph comes from
/// `navigationItemsBase` / `serviceSubItemsBase` in
/// `src/app/dashboard/layout.tsx`, and the copy from `nav.*` in `i18n.ts`.
///
/// Presented as a route rather than `Scaffold.drawer`. Two reasons: the frame
/// draws it over the **whole** 844, bottom nav included, and home's `Scaffold`
/// is nested inside `HomeShell`'s — so a `drawer:` on the inner one would stop
/// at the nav bar, and putting it on the shell would mean threading a
/// `GlobalKey<ScaffoldState>` down to the menu button. A route also means the
/// menu works unchanged from any screen that grows a menu button later.
Future<void> openMenuDrawer(BuildContext context, {int? connectedPages}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      // The frame's scrim is black at **70%**; `AppColors.scrim` is 80% and
      // belongs to the bottom sheet. Inlined at the frame's value rather than
      // added to the palette, the same call `MenuButton` makes for
      // `line/edge` (brief §21.9).
      barrierColor: const Color(0xB3000000),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => MenuDrawer(connectedPages: connectedPages),
      transitionsBuilder: (context, animation, _, child) {
        // The drawer comes from the edge it rests on, and it rests on the
        // **start** edge — left in French and English, right in Arabic, which
        // is where `AlignmentDirectional.centerStart` puts it and where the
        // menu button that opens it sits.
        //
        // So the travel has to mirror with the rest. `SlideTransition` negates
        // the x offset itself when handed an RTL `textDirection`, which keeps
        // `begin` readable as "one panel-width off the start edge" instead of
        // making the caller pick a sign. Without it the panel flew in from the
        // left in Arabic and crossed the whole screen to land on the right.
        final slide = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(slide),
          textDirection: Directionality.of(context),
          child: child,
        );
      },
    ),
  );
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key, this.connectedPages});

  /// Connected pages, for the plan box. See [_PlanBox.connectedPages] for why
  /// it is handed in rather than fetched.
  final int? connectedPages;

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  /// Services is the one group the frame draws open, matching the web, which
  /// expands whichever group the current route lives under. Local state: the
  /// drawer is closed and rebuilt each time, and a merchant's last expansion
  /// is not worth persisting.
  bool _servicesOpen = true;

  /// Unread notifications, for the badge on that row.
  ///
  /// Fetched here rather than handed in, unlike [MenuDrawer.connectedPages]:
  /// nobody else holds this number. Home does not load it — it has no use for
  /// it — so passing it in would have meant adding a fifth request to every
  /// home load and refresh for a figure only visible once the drawer opens.
  /// Fetching on open also means it is fresh at the moment it is read.
  ///
  /// Stays null until it answers, and **stays null if the request fails**: a
  /// badge is a claim about how much is waiting, and `0` is the wrong thing to
  /// claim when the truth is "we could not ask".
  int? _unread;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    final result = await context.read<NotificationRepository>().unreadCount();
    if (!mounted) return;
    result.fold(
      onSuccess: (count) => setState(() => _unread = count),
      // Deliberately silent. The drawer opened to navigate; a toast about a
      // badge that failed to load would be noise over the thing the merchant
      // actually came here to tap.
      onFailure: (_) {},
    );
  }

  void _close() => Navigator.of(context).pop();

  /// Closes the drawer, then goes.
  ///
  /// In this order because the drawer is a route: leaving it on the stack
  /// while `go` replaces what is underneath would strand it over the new
  /// screen.
  void _goTo(String route) {
    final router = GoRouter.of(context);
    _close();
    router.go(route);
  }

  /// For a destination whose screen does not exist yet.
  ///
  /// The drawer stays open on purpose — closing it to show a toast would tell
  /// the merchant "that did nothing" twice over. The same choice home makes
  /// for its four unbuilt actions (§23.6).
  void _notBuilt(String what) {
    AppToast.info(context, '$what — ${L10n.of(context).commonNotBuilt}');
  }

  /// For Analyses and Rapports, which are **not** unbuilt — they are
  /// deliberately web-only (brief §14.3: reports and analytics are desk work).
  /// Their icons stay muted for the same reason, so grey plus this line say
  /// the same thing: not missing, elsewhere.
  void _onWebOnly(String what) {
    AppToast.info(context, '$what — ${L10n.of(context).menuWebOnly}');
  }

  Future<void> _signOut() async {
    final session = context.read<SessionViewModel>();
    final router = GoRouter.of(context);

    _close();
    await session.signOut();
    // Explicit, rather than left to the redirect: a merchant who has signed in
    // before has seen onboarding once, and the redirect would send them back
    // through it. Carried over from the stand-in sheet this drawer replaces.
    router.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final user = context.watch<SessionViewModel>().user;

    // `SafeArea` takes physical sides, so unlike everything else here it has
    // to be mirrored by hand. See its use below.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: AppColors.ink,
        child: Container(
          // 336 of the frame's 390 — the remaining 54 is what keeps the dimmed
          // screen behind it visible, so the drawer reads as covering home
          // rather than as a screen of its own.
          width: 86.15.w, // 336
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            border: BorderDirectional(
              end: BorderSide(color: AppColors.rule),
            ),
          ),
          child: SafeArea(
            // The inset belongs on the screen edge the panel is flush
            // against, and nowhere else — applying it to the interior edge
            // would indent the rows away from an edge that has no system
            // furniture behind it. The panel sits on the **start** edge, so
            // that is the left in French and English and the right in Arabic.
            left: !isRtl,
            right: isRtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DrawerHeader(onClose: _close),
                // Scrolls because the plan box falls below the fold on a
                // 640dp-tall handset, and this market's screens are short.
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: AppSpacing.xxxl), // 32
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutterTight, // 16
                        ),
                        child: ListBox(children: _navigation(l10n)),
                      ),
                      SizedBox(height: AppSpacing.xxl), // 24
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutterTight,
                        ),
                        child: _PlanBox(
                          user: user,
                          l10n: l10n,
                          connectedPages: widget.connectedPages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The eight rows and three subrows, in the web sidebar's own order.
  ///
  /// The Services group is one child of [ListBox] rather than four, because
  /// its subrows carry no dividers — the group is a single band in the frame,
  /// and `ListBox` rules between its children.
  List<Widget> _navigation(L10n l10n) => [
        MenuRow(
          icon: AppIcons.home,
          label: l10n.menuOverview,
          iconColor: AppColors.textPrimary,
          // Already here. Closes rather than re-navigating, which would
          // rebuild home and throw away the data it has loaded.
          onTap: _close,
        ),
        MenuRow(
          icon: AppIcons.message,
          label: l10n.menuInbox,
          // `accent/inbound`. §21.3's category for a message arriving, which is
          // exactly what an inbox holds. It was `signal/live` — the AI's own
          // colour — which said "the agent is here" on the one row that is
          // about the customer rather than the agent.
          iconColor: AppColors.accentInbound,
          onTap: () => _goTo(Routes.inbox),
        ),
        MenuRow(
          icon: AppIcons.chat,
          label: l10n.menuSocial,
          // `accent/clients` — §21.3's violet for people. A connected Page is
          // where the merchant's customers are, and the row below it (Services)
          // is where their own tools start, so the two should not share a hue.
          iconColor: AppColors.accentClients,
          // Connected pages, and shown **even at zero** — the web's own rule
          // (`layout.tsx:355`: `item.id === 'social-media' ? pages.length`,
          // with no `> 0` guard). "0 pages" is a fact a merchant needs on the
          // row that would let them fix it; contrast the notifications badge
          // below, which the web hides at zero.
          count: widget.connectedPages?.toString(),
          onTap: () => _notBuilt(l10n.menuSocial),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuRow(
              icon: AppIcons.grid,
              label: l10n.menuServices,
              iconColor: AppColors.textPrimary,
              expanded: _servicesOpen,
              onTap: () => setState(() => _servicesOpen = !_servicesOpen),
            ),
            if (_servicesOpen) ...[
              MenuSubrow(
                icon: AppIcons.box,
                label: l10n.menuProducts,
                // Catalogue is amber (§21.3).
                iconColor: AppColors.accentStarred,
                onTap: () => _goTo(Routes.products),
              ),
              MenuSubrow(
                icon: AppIcons.bot,
                label: l10n.menuAgents,
                // The AI is `signal/live`.
                iconColor: AppColors.live,
                onTap: () => _goTo(Routes.agents),
              ),
              MenuSubrow(
                icon: AppIcons.megaphone,
                label: l10n.menuCommercial,
                // Muted, and inert: the web ships it `active: false` with a
                // null href, so it is not a destination on either client.
                trailing: l10n.menuSoon,
              ),
            ],
          ],
        ),
        MenuRow(
          icon: AppIcons.bell,
          label: l10n.menuNotifications,
          // Alerts are red.
          iconColor: AppColors.accentAlert,
          // Only when there is something unread — again the web's rule, which
          // guards this one and not the pages one
          // (`item.id === 'notifications' && unreadCount > 0`). A standing
          // `0` next to a bell would read as a broken badge.
          count: (_unread ?? 0) > 0 ? _unread.toString() : null,
          onTap: () => _goTo(Routes.notifications),
        ),
        MenuRow(
          icon: AppIcons.chart,
          label: l10n.menuAnalytics,
          onTap: () => _onWebOnly(l10n.menuAnalytics),
        ),
        MenuRow(
          icon: AppIcons.fileText,
          label: l10n.menuReports,
          onTap: () => _onWebOnly(l10n.menuReports),
        ),
        MenuRow(
          icon: AppIcons.settings,
          label: l10n.menuSettings,
          iconColor: AppColors.textPrimary,
          onTap: () => _goTo(Routes.settings),
        ),
        // NOT IN THE FRAME. Added because the frame has no way out of a
        // session and this drawer replaces the stand-in sheet that held the
        // only one (§23.12) — shipping it as drawn would strand a merchant
        // signed in forever. `11a — Profil` is where the design puts
        // Déconnexion; when that screen is built this row can move there.
        MenuRow(
          icon: AppIcons.logout,
          label: l10n.menuSignOut,
          // White, like the other actions. It had been left on `MenuRow`'s
          // `text/muted` default, which in this drawer is the colour of the
          // three rows you cannot use — so the one row that always works read
          // as the most disabled thing on screen.
          iconColor: AppColors.textPrimary,
          onTap: _signOut,
        ),
      ];
}

/// The drawer's own header: a close control where home's menu button was, and
/// the lockup **with** its tagline.
///
/// The tagline is off in home's header and on here — the frame's own call, and
/// a reasonable one: this is the only place in the app with room for it.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.gutterTight, // 16
        end: AppSpacing.gutter, // 20
        top: AppSpacing.xs, // 4
        bottom: AppSpacing.xl, // 20
      ),
      child: Row(
        children: [
          // The same `Menu Button` frame as home's, carrying `Icon/Close`
          // instead of `Icon/Menu`: the control does not move when the drawer
          // opens, it changes what it does. Reusing `MenuButton` would have
          // meant a hardcoded hamburger.
          _CloseButton(onTap: onClose),
          SizedBox(width: AppSpacing.md), // 12
          // `Expanded` + `FittedBox(scaleDown)`, exactly as home's header
          // does (§23.9). Found by the Arabic test: the drawer gives this row
          // 299, and the lockup plus the Arabic tagline overflowed it by 14 —
          // which clips a wordmark rather than shrinking it. Same defect as
          // home's 51px overflow, same fix, and the reason it was invisible
          // is the same too: nothing had rendered this header in Arabic.
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: DjaberLogo(size: 34, showTagline: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm), // 8
        decoration: BoxDecoration(
          color: AppColors.surface,
          // `line/edge`, 12% — see `MenuButton`.
          border: Border.all(color: const Color(0x1FFFFFFF)),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: AppIcon(
          AppIcons.close,
          size: 6.15.w, // 24
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// `Votre plan` — two `List Row`s pinned under the navigation.
///
/// **Real data, not the frame's.** The frame says `Pro` and `2 / 10`, and the
/// file disagrees with itself four ways about the plan (§23.10): home shows
/// 3 760 / 5 000 credits, the menu says Pro and 2/10 pages, `11` says
/// Individual, `12` says 2/∞. The live account is **Individual with a 500
/// credit allowance**, verified against `/api/auth/profile`. Reading the
/// session settles it the way home already did — a fifth hardcoded answer
/// would be the worst of the five.
///
/// The page count is deliberately absent rather than guessed: the plan's page
/// cap is not on the user record, and home's `Pages connectées` KPI already
/// carries the live figure. Credits are what the drawer can state truthfully,
/// and they are the number that matters — when they run out the AI stops.
///
/// **The second row is pages, not credits** — what the web's own sidebar puts
/// here (`dash.pages`, `layout.tsx:491`). Verified against the live app on
/// 2026-09-10, which reads `Votre plan — individual` and `Pages — 0 / 10`.
///
/// Credits were tried here first and were wrong twice over: the header pill
/// already carries them, and it reads *remaining* while this box read *used*,
/// so one account showed `⚡ 500 / 500` above `0 / 500` at the same moment —
/// two readings of one allowance, which looks like a contradiction rather than
/// two facts. Pages is the figure the drawer adds that the header does not.
///
/// **The `/ 10` is the web's own hardcoded literal**, not a plan limit:
/// `layout.tsx:492` is `{pages.length} / 10` regardless of plan, which is why
/// this Individual account shows a cap of 10 while §21.1 records Individual as
/// one page. Ported as-is because the web is the source of truth and a
/// different number here would be a second wrong answer, but it is wrong on
/// both clients and wants fixing on the backend, where the real cap lives.
class _PlanBox extends StatelessWidget {
  const _PlanBox({
    required this.user,
    required this.l10n,
    required this.connectedPages,
  });

  final User? user;
  final L10n l10n;

  /// Connected pages, passed in from whoever opened the drawer.
  ///
  /// Not fetched here: home has already loaded `GET /api/pages` for its own
  /// KPI, and a second request on every menu open would be a slower, staler
  /// copy of a number the caller is holding. Null means "not known yet", and
  /// hides the row rather than showing `0 / 10` — which would read as "no
  /// pages" on a merchant who has two.
  final int? connectedPages;

  /// The web's cap, hardcoded there and therefore hardcoded here. See the
  /// class comment — this is faithfulness, not a limit we believe in.
  static const _webPageCap = 10;

  @override
  Widget build(BuildContext context) {
    final plan = user?.plan;
    final pages = connectedPages;

    return ListBox(
      children: [
        AppListRow(
          // Capitalised, not upper-cased: the backend answers `individual`
          // and the web renders it in a badge as a proper noun.
          title: plan == null || plan.isEmpty
              ? l10n.menuPlanUnknown
              : plan[0].toUpperCase() + plan.substring(1),
          meta: l10n.menuPlan,
        ),
        if (pages != null)
          AppListRow(
            // A single run of digits and separators, which bidi leaves in
            // reading order under RTL — so no `Directionality` wrapper, unlike
            // home's pill, which wraps a *Row* whose bolt would flip (§21.8).
            title: '$pages / $_webPageCap',
            meta: l10n.menuPages,
          ),
      ],
    );
  }
}

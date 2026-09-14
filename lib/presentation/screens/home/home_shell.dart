import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_icon.dart';

/// The five bottom-nav destinations of brief §16, wrapped in the frame's own
/// nav bar.
///
/// It lives in a `ShellRoute` so the bar is built once and does not rebuild or
/// animate when the tab changes — switching tabs swaps the body under a bar
/// that never moves.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  /// In the frame's order: Accueil, File, Boîte, Stock, Commandes.
  static List<NavDestination> _destinations(L10n l10n) => [
        NavDestination(
          icon: AppIcons.home,
          label: l10n.navHome,
          route: Routes.home,
        ),
        NavDestination(
          icon: AppIcons.bell,
          label: l10n.navQueue,
          route: Routes.queue,
        ),
        NavDestination(
          icon: AppIcons.chat,
          label: l10n.navInbox,
          route: Routes.inbox,
        ),
        NavDestination(
          icon: AppIcons.box,
          label: l10n.navStock,
          route: Routes.stock,
        ),
        NavDestination(
          icon: AppIcons.clipboard,
          label: l10n.navOrders,
          route: Routes.orders,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(L10n.of(context));
    final location = GoRouterState.of(context).matchedLocation;

    // Falls back to Accueil rather than to "none": a route pushed over the
    // shell should leave the bar showing where it came from, not blank.
    final current = destinations.indexWhere((d) => d.route == location);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: child,
      bottomNavigationBar: AppBottomNav(
        destinations: destinations,
        currentIndex: current < 0 ? 0 : current,
        // `go`, not `push`: these are peers, and a tab must not stack on the
        // tab before it — that is what made back exit the app (brief §21.7).
        onSelect: (index) => context.go(destinations[index].route),
      ),
    );
  }
}

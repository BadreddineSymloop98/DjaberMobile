import 'package:flutter/widgets.dart';

/// The root navigator's observer, so a screen can know when it is uncovered.
///
/// A screen that must refetch when the screen above it closes mixes in
/// `RouteAware`, subscribes to this, and refreshes in `didPopNext`. That is
/// the only signal that fires for **every** way the screen above can go —
/// a pop carrying a value, a pop carrying nothing, the system back button,
/// the iOS swipe. Reading the value a pop happens to carry covers one of
/// those, which is how a saved edit could leave the product behind it stale.
///
/// Registered on `GoRouter(observers:)` in `router.dart`, which is the root
/// navigator; screens on the shell navigator do not see it.
///
/// **`PageRoute`, not `ModalRoute`.** `RouteObserver` notifies only when the
/// route that popped *and* the one underneath are both its type, so this one
/// stays quiet for bottom sheets and dialogs. A screen refreshing because its
/// own filter sheet closed would fire a request per open, and the screens that
/// do want a sheet's result already await it.
final appRouteObserver = RouteObserver<PageRoute<void>>();

/// Fires when a screen pushed **over the bottom-nav shell** closes.
///
/// A tab screen cannot use [appRouteObserver] directly. The tabs live on the
/// shell's own navigator, while everything pushed from them — New order, a
/// product, the settings — is pushed on the **root** navigator. So when one of
/// those closes, the root observer reports the route underneath as the
/// *shell's* page, never the tab inside it, and the tab's own `didPopNext`
/// never fires. That is exactly why a freshly created order did not appear
/// until the list was pulled down.
///
/// The shell is on the root navigator, so it *does* get the callback. It bumps
/// this, and whichever tab is showing refreshes. `ShellRoute` keeps only the
/// current tab's screen alive, so a notification always means "the tab the
/// merchant is looking at is stale".
final shellReturns = ShellReturnNotifier();

class ShellReturnNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../app/route_observer.dart';
import '../../viewmodels/session_view_model.dart';
import 'splash_screen.dart';

/// The splash, played again over the app when the merchant comes back to it.
///
/// Sits in `MaterialApp.builder`, above the router, and covers it while
/// [SessionViewModel.isReplayingSplash] is set. Nothing underneath is touched:
/// the screens, the stack under them, any open bottom sheet or dialog and
/// every field's text are exactly as the merchant left them when the logo
/// goes. That is the whole point — see [SessionViewModel.replaySplash].
///
/// Two things the splash *route* used to do for free, done here instead:
///
/// - **Back is swallowed** while it plays, as the route's `PopScope` did.
///   Without that, back would pop the screen hidden under the logo. It works
///   because this widget is the router's parent: its `initState` runs first, so
///   it registers with the binding before the router's back dispatcher does,
///   and the binding asks observers in the order they registered.
/// - **The tab on screen refreshes** when it ends. Rebuilding the screen used
///   to reload it; now [shellReturns] says so, as it does when a pushed screen
///   closes.
class SplashReplayOverlay extends StatefulWidget {
  const SplashReplayOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<SplashReplayOverlay> createState() => _SplashReplayOverlayState();
}

class _SplashReplayOverlayState extends State<SplashReplayOverlay> with WidgetsBindingObserver {
  late final SessionViewModel _session = context.read<SessionViewModel>();
  bool _replaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _replaying = _session.isReplayingSplash;
    _session.addListener(_onSession);
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onSession() {
    final replaying = _session.isReplayingSplash;
    if (replaying == _replaying) return;
    setState(() => _replaying = replaying);
    if (!replaying) shellReturns.bump();
  }

  @override
  Future<bool> didPopRoute() async => _replaying;

  @override
  Widget build(BuildContext context) {
    // The app stays first, and alone at its index, so covering and uncovering
    // it never rebuilds it from scratch.
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_replaying) const BlockSemantics(child: SplashScreen.replay()),
      ],
    );
  }
}

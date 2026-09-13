import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';
import 'app_toast.dart';

/// Requires two back presses to leave the app, and says so after the first.
///
/// ## Why every top-level screen needs this
///
/// The app navigates with `go`, not `push` — every screen *replaces* the last,
/// which is deliberate: tabs are peers, and stacking them is what made back
/// exit the app from the middle of the tutorial (brief §22.6). The
/// consequence is that the navigation stack is only ever one deep, so on
/// **every** top-level screen there is nothing for a back press to pop and
/// Android takes it as "close the app".
///
/// That is defensible on home — it is the app's root, and leaving from the
/// root is what back means. It is not defensible *silently*, and it is not
/// defensible at all on a screen a merchant reached from somewhere else: they
/// press back expecting to go back, and the app vanishes with whatever they
/// were doing.
///
/// So the first press explains itself and the second obeys. Two seconds is
/// long enough to read the line and short enough that a deliberate
/// double-press still feels like one gesture.
///
/// **Not for pushed routes.** The menu drawer and the OAuth web view are
/// pushed above the current screen, so their own route consumes back and pops
/// normally — this guard sits under them and never sees it. The tutorial has
/// its own `PopScope` for the same reason and does not use this.
class ExitGuard extends StatefulWidget {
  const ExitGuard({super.key, required this.child});

  final Widget child;

  /// How long the first press stays armed.
  static const window = Duration(seconds: 2);

  @override
  State<ExitGuard> createState() => _ExitGuardState();
}

class _ExitGuardState extends State<ExitGuard> {
  /// Disarms itself, rather than the state being derived from a timestamp.
  ///
  /// A `DateTime.now()` comparison would read the wall clock, which no test
  /// can advance — `tester.pump(duration)` moves Flutter's own clock and
  /// leaves `now()` where it was, so the expiry could never be exercised. A
  /// timer is both testable and simpler: there is no arithmetic, and the armed
  /// state is exactly "is the timer still running".
  Timer? _disarm;

  bool get _armed => _disarm?.isActive ?? false;

  void _onBack() {
    if (_armed) {
      _disarm?.cancel();
      // `SystemNavigator.pop` rather than `Navigator.pop`: there is nothing in
      // the Flutter stack to pop, which is the whole reason this exists.
      SystemNavigator.pop();
      return;
    }
    _disarm?.cancel();
    _disarm = Timer(ExitGuard.window, () {});
    AppToast.info(context, L10n.of(context).exitHint);
  }

  @override
  void dispose() {
    _disarm?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Always false: the pop is performed by hand, and only on the second
      // press. Leaving it true would let the first press through.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: widget.child,
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import 'app_toast.dart';

/// What the system back button does on a route. **The only `PopScope` on a
/// go_router page.** `router.dart` puts one around every page builder and
/// names that page's parent there, so the policy is in one place.
///
/// The rule it enforces: *"Tap again to leave" only where back would really
/// close the app; everywhere else, back goes to the previous screen, unless
/// unsaved work needs a confirmation first.* One press runs these steps in
/// order:
///
/// 1. An active [BackIntercept] below this scope goes first: a dirty form asks,
///    a busy step ignores the press, a pager steps back a page.
/// 2. If a route is really below this one, it pops. With no intercept active,
///    [PopScope.canPop] is simply true and the navigator pops by itself, so
///    predictive back and the iOS swipe keep their animations.
/// 3. With nothing below, it goes to [fallback], the route's declared parent.
///    The stack is often empty here: screens are reached with `go`, from a
///    deep link, or restored by the splash replay, which keeps only the top
///    location.
/// 4. With no parent either, this is a root ([BackScope.root]). The first press
///    shows `exitHint` and a second press within [exitWindow] leaves the app.
///    The toast is structural: it can only show when nothing is below and the
///    router declared no parent.
///
/// **Why not `GoRoute.onExit`.** go_router 18 does consult it when back has
/// nothing to pop, but it also runs on every `go` and `pop` that removes the
/// route, so a fallback there would block ordinary navigation.
///
/// **Only on root-navigator pages and the ShellRoute builder.** A scope inside
/// a shell tab would read the shell navigator's single page and never see a
/// route below. Its `ModalRoute` is the page it wraps.
///
/// **No `GoRouter.of` in build.** Widget tests host screens in
/// `MaterialApp(home:)`; the router is looked up only inside callbacks, and
/// its absence just skips the fallback.
///
/// **Known limit:** an Android 14 predictive-back gesture that is already in
/// flight keeps the `canPop` it started with. An intercept that turns active
/// mid-gesture (a composer typed into while swiping) does not stop that one pop.
class BackScope extends StatefulWidget {
  const BackScope({super.key, required this.fallback, required this.child});

  /// A root: nothing below it and no parent, so back leaves the app, asking
  /// first.
  const BackScope.root({super.key, required this.child}) : fallback = null;

  /// Where back goes when nothing is below this route. Null means a root.
  final String? fallback;

  final Widget child;

  /// How long the first press on a root stays armed. Long enough to read the
  /// line, short enough that a deliberate double press still feels like one
  /// gesture.
  static const exitWindow = Duration(seconds: 2);

  /// The on-screen back arrow. It takes **exactly** the path Android back
  /// takes (the shell navigator first, then the root, then this scope), so
  /// the two cannot disagree and the fallback exists only in `router.dart`.
  static Future<void> back(BuildContext context) async {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      await router.routerDelegate.popRoute();
    } else {
      await Navigator.maybePop(context);
    }
  }

  @override
  State<BackScope> createState() => _BackScopeState();
}

class _BackScopeState extends State<BackScope> {
  final _intercepts = <_BackInterceptState>[];

  /// Disarms itself instead of comparing timestamps: `tester.pump(duration)`
  /// advances Flutter's clock, not `DateTime.now()`, so only a timer lets a
  /// test exercise the expiry. The root is armed exactly while it runs.
  Timer? _disarm;

  /// Guards against a second press while the first is still awaiting a leave
  /// sheet. Reset in `finally`, so a throwing `onBack` cannot wedge the scope.
  bool _handling = false;

  bool _rebuildScheduled = false;

  _BackInterceptState? get _activeIntercept {
    for (final intercept in _intercepts.reversed) {
      if (intercept.widget.active) return intercept;
    }
    return null;
  }

  void _register(_BackInterceptState intercept) {
    if (!_intercepts.contains(intercept)) _intercepts.add(intercept);
    _markChanged();
  }

  void _unregister(_BackInterceptState intercept) {
    if (_intercepts.remove(intercept)) _markChanged();
  }

  /// Intercepts report from their own build or lifecycle, often mid-build, so
  /// the rebuild is deferred to the end of the frame. A `setState` from there
  /// would throw "setState() called during build".
  void _markChanged() {
    if (_rebuildScheduled || !mounted) return;
    _rebuildScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _rebuildScheduled = false;
      if (mounted) setState(() {});
    });
    // Make sure a frame follows even when nothing else is animating.
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  void didUpdateWidget(BackScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The shell's scope moves between root (home) and a fallback (other
    // tabs). A press armed on home must never count on another tab.
    if (oldWidget.fallback != widget.fallback) _disarm?.cancel();
  }

  @override
  void deactivate() {
    _disarm?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _disarm?.cancel();
    super.dispose();
  }

  Future<void> _handle() async {
    if (_handling) return;
    _handling = true;
    try {
      // Everything that needs the tree is read before any await: the route can
      // be gone afterwards (a splash replay, a notification `go`).
      final navigator = Navigator.maybeOf(context);
      final route = ModalRoute.of(context);
      final router = GoRouter.maybeOf(context);
      final l10n = L10n.of(context);

      final intercept = _activeIntercept;
      var confirmed = false;
      if (intercept != null) {
        if (!await intercept.widget.onBack()) return;
        if (!mounted) return;
        confirmed = true;
      }

      if (route?.canPop ?? false) {
        navigator?.pop();
        return;
      }

      final fallback = widget.fallback;
      if (fallback != null) {
        _disarm?.cancel();
        // After the current pop dispatch has unwound: go_router is still
        // inside its own `popRoute` here.
        scheduleMicrotask(() => router?.go(fallback));
        return;
      }

      // A root. A confirmed leave sheet already asked, so it does not ask twice.
      if (confirmed || (_disarm?.isActive ?? false)) {
        _disarm?.cancel();
        // `SystemNavigator.pop`, not `Navigator.pop`: nothing in the Flutter
        // stack is left to pop.
        await SystemNavigator.pop();
        return;
      }
      _disarm = Timer(BackScope.exitWindow, () {});
      if (mounted) AppToast.info(context, l10n.exitHint);
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // A dependency on the route's status, so this rebuilds when a route is
    // pushed below or removed.
    final hasRouteBelow = ModalRoute.of(context)?.canPop ?? false;
    return _BackScopeRegistry(
      scope: this,
      child: PopScope(
        canPop: hasRouteBelow && _activeIntercept == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handle();
        },
        child: widget.child,
      ),
    );
  }
}

class _BackScopeRegistry extends InheritedWidget {
  const _BackScopeRegistry({required this.scope, required super.child});

  final _BackScopeState scope;

  @override
  bool updateShouldNotify(_BackScopeRegistry oldWidget) => scope != oldWidget.scope;
}

/// A screen saying "I need to see back": a dirty form, a busy request, an
/// inner pager.
///
/// [onBack] returns true to let the leave go on (to the route below, the
/// fallback, or out of the app on a root without a second press) and false to
/// consume the press. **It must not pop by itself and then return true**;
/// that would pop twice.
///
/// It registers with the nearest [BackScope], so a route keeps exactly one
/// `PopScope`. Nested `PopScope`s all fire on one press, because `ModalRoute`
/// calls every `PopEntry`. With no scope above it (a pageless route such as a
/// sheet or a web view, or a bare widget test), it builds its own `PopScope`
/// and pops its route itself once [onBack] agrees.
///
/// Explicit navigation (`pop(result)` after a save, `go`) bypasses `PopScope`,
/// so success paths never ask.
class BackIntercept extends StatefulWidget {
  const BackIntercept({
    super.key,
    required this.active,
    required this.onBack,
    required this.child,
  });

  final bool active;
  final FutureOr<bool> Function() onBack;
  final Widget child;

  @override
  State<BackIntercept> createState() => _BackInterceptState();
}

class _BackInterceptState extends State<BackIntercept> {
  _BackScopeState? _scope;
  bool _handling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = context.getInheritedWidgetOfExactType<_BackScopeRegistry>()?.scope;
    // A scope on another route (a sheet over a page) is not ours: overlays
    // are not descendants, so this only matches the page we are on.
    if (scope != _scope) {
      _scope?._unregister(this);
      _scope = scope;
      _scope?._register(this);
    }
  }

  @override
  void didUpdateWidget(BackIntercept oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _scope?._markChanged();
  }

  @override
  void dispose() {
    _scope?._unregister(this);
    super.dispose();
  }

  Future<void> _standalone() async {
    if (_handling) return;
    _handling = true;
    try {
      final navigator = Navigator.of(context);
      final route = ModalRoute.of(context);
      if (!await widget.onBack()) return;
      if (!mounted || !(route?.isCurrent ?? false)) return;
      navigator.pop();
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_scope != null) return widget.child;
    return PopScope(
      canPop: !widget.active,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _standalone();
      },
      child: widget.child,
    );
  }
}

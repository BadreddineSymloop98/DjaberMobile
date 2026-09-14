import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/extensions/responsive_extension.dart';

/// Reveals its child by sliding it up into place while fading it in.
///
/// The app's one entrance motion. It is used for the splash logo and for the
/// artwork on each onboarding slide, so the two screens read as the same
/// gesture rather than two separately-invented animations.
///
/// Kept short and translation-only on purpose: brief §9 targets low-end
/// Xiaomi / Oppo / Infinix hardware, where a long or scaled animation reads as
/// lag rather than polish. A vertical rise also needs no mirroring for Arabic —
/// consistent with the §15 decision that direction is physical, not linguistic.
class RiseFade extends StatefulWidget {
  const RiseFade({
    super.key,
    required this.child,
    this.animate = true,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;

  /// Plays when this turns true, and **latches** — once revealed the child
  /// stays revealed. Onboarding relies on that: swiping back to a slide the
  /// merchant has already seen shows it immediately instead of replaying, so
  /// the animation is a first impression rather than a toll on every swipe.
  final bool animate;

  /// Stagger. Give successive elements 60–120ms apart.
  final Duration delay;

  final Duration duration;

  /// How far below its final position the child starts. Defaults to 2.4% of
  /// the screen height — about 20dp on the 844-tall design frame. A runtime
  /// value, so it cannot be a default argument.
  final double? offset;

  final Curve curve;

  @override
  State<RiseFade> createState() => _RiseFadeState();
}

/// 2.4% of the screen height — about 20dp on the 844-tall design frame.
const double _defaultRise = 2.4;

class _RiseFadeState extends State<RiseFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  Timer? _timer;

  double get _riseDistance => widget.offset ?? _defaultRise.h;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _play();
  }

  @override
  void didUpdateWidget(RiseFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) _play();
  }

  void _play() {
    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "Remove animations" in the OS accessibility settings means show the end
    // state, not a hidden one.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _curve,
      child: AnimatedBuilder(
        animation: _curve,
        // Passed as `child` so the subtree is built once and only the
        // transform is recomputed per frame.
        child: widget.child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _riseDistance * (1 - _curve.value)),
          child: child,
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import '../utils/screen.dart';

/// Percentage-of-screen sizing.
///
/// ```dart
/// SizedBox(height: 2.h)        // 2% of the screen height
/// Container(width: 45.w)       // 45% of the screen width
/// EdgeInsets.all(4.w)
/// ```
///
/// Declared on [num] rather than `int` so both `12.h` and `2.5.h` work; every
/// `int` is a `num`, so the integer form asked for is covered.
///
/// Reads [Screen], which is refreshed by `ScreenInitializer` on every metric
/// change, so these values follow rotation and split-screen automatically.
extension ResponsiveNum on num {
  /// Percentage of the full screen height.
  double get h => Screen.height * this / 100;

  /// Percentage of the full screen width.
  double get w => Screen.width * this / 100;

  /// Percentage of the *usable* height — status bar and gesture bar removed.
  /// Use this when sizing a page body so content is not pushed under the
  /// system UI on tall Android devices with a punch-hole camera.
  double get sh => Screen.safeHeight * this / 100;

  /// Percentage of the shorter edge. For anything that should stay square or
  /// keep its proportion in landscape — radii, avatars, icon boxes.
  double get r => Screen.shortestSide * this / 100;

  /// Font size in logical pixels, scaled against a 390dp-wide reference (the
  /// Figma frame width) and clamped so text neither collapses on a 320dp
  /// handset nor balloons on a tablet.
  ///
  /// Type is deliberately *not* a raw percentage of width: at 3.w a heading is
  /// 9px on a small phone and 30px on a tablet, which is unreadable at both
  /// ends. Use `.sp` for every font size.
  double get sp {
    const referenceWidth = 390.0;
    final factor = (Screen.width / referenceWidth).clamp(0.85, 1.15);
    return this * factor;
  }
}

/// Absolute sizing that still respects very small screens.
///
/// Some values should not scale with the viewport at all — a 1px hairline is
/// 1px everywhere, and an icon that is 24dp in the design stays 24dp. Use
/// [dp] for those, and reserve `.h` / `.w` for layout proportions.
extension AbsoluteNum on num {
  /// A design-system pixel value, shrunk only on genuinely small handsets.
  double get dp => Screen.isSmall ? toDouble() * 0.92 : toDouble();
}

/// Small numeric helpers used across view models.
extension NumClamp on num {
  double clampTo(double min, double max) =>
      math.min(math.max(toDouble(), min), max);
}

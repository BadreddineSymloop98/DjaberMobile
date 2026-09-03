import '../../core/extensions/responsive_extension.dart';

/// Spacing, radii and stroke widths — all proportional to the screen.
///
/// Every value is a percentage of screen width via `.w`, expressed against the
/// 390×844 design frame. The comment on each line is the dp it resolves to on
/// that frame, so the Figma number stays readable next to the percentage.
///
/// Width rather than height, even for vertical gaps: a rhythm built half on
/// width and half on height comes apart on any handset whose aspect ratio
/// differs from the frame's, and phones vary far more in height than in width.
/// `.h` is used where a dimension genuinely tracks the height of the screen —
/// a sheet at 60% of it, say — not for spacing.
///
/// These are getters, not constants, because [Screen] is only known at runtime.
/// That is why call sites cannot be `const`.
class AppSpacing {
  const AppSpacing._();

  static double get xxs => 0.51.w; // 2
  static double get xs => 1.03.w; // 4
  static double get sm => 2.05.w; // 8
  static double get md => 3.08.w; // 12
  static double get lg => 4.10.w; // 16
  static double get xl => 5.13.w; // 20
  static double get xxl => 6.15.w; // 24
  static double get xxxl => 8.21.w; // 32
  static double get huge => 12.31.w; // 48

  /// Screen side gutter. The design frames are 390 wide with a 20 gutter.
  static double get gutter => 5.13.w; // 20

  /// The tighter gutter used inside a card.
  static double get gutterTight => 4.10.w; // 16

  /// The room before a primary action on the sign-up form.
  ///
  /// Wider than the 16 between fields, so the button reads as the end of the
  /// form rather than another row in it. Login keeps 16 — the control above
  /// its button is a 16px checkbox, not a field, so it needs less air.
  static double get beforeAction => 8.72.w; // 34

}

class AppRadius {
  const AppRadius._();

  /// The web's `rounded-lg`. Every card, tile and button (brief §15).
  static double get card => 2.05.w; // 8

  /// `rounded-md` — inputs and small chips.
  static double get input => 2.05.w; // 8

  static double get sheet => 4.10.w; // 16

  /// A pill: status chips, badges. Not a size — a sentinel meaning "fully
  /// rounded" — so it stays absolute.
  static const double pill = 999;
}

/// Fixed control heights.
///
/// One number for every tappable control, so a button and the field above it
/// cannot drift apart. In Figma the Primary Button is 42 and the Text Field
/// input is 41 — they differ only because the label inside each is a different
/// size, not by intent. Pinning both to the button height makes them match and
/// keeps every form on one rhythm.
class AppSize {
  const AppSize._();

  /// 42 on the 844-tall design frame. Buttons and text inputs.
  static double get control => 4.98.h;
}

class AppStroke {
  const AppStroke._();

  /// A hairline. **Deliberately not scaled.**
  ///
  /// The whole design system is built on 1px rules, and a scaled hairline
  /// lands on a fractional logical pixel — 1.05 on a 411dp handset — which the
  /// rasteriser renders as a grey blur instead of a line. Every border in the
  /// app would soften. One logical pixel is one logical pixel.
  static const double hairline = 1;
}

class AppDuration {
  const AppDuration._();

  /// Motion is deliberately short. Platform-default curves are one of the four
  /// things that make an app read as Android (brief §15), and on the low-end
  /// hardware this app targets a long animation reads as lag, not polish.
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
}

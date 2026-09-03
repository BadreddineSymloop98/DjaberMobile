/// Spacing, radii and stroke widths.
///
/// These are the Figma `Space & Form` collection (brief §17 progress note),
/// kept as fixed dp rather than percentages: a 16dp gutter is 16dp on every
/// handset, and running spacing through `.w` makes padding grow on a tablet
/// while type does not, which pulls layouts apart. Use `.h` / `.w` for
/// proportional layout — a sheet at 60% of the screen — and these for rhythm.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Screen side gutter. The Figma frames are 390 wide with a 20 gutter.
  static const double gutter = 20;

  /// The tighter gutter used inside a card.
  static const double gutterTight = 16;
}

class AppRadius {
  const AppRadius._();

  /// The web's `rounded-lg`. Every card, tile and button (brief §15).
  static const double card = 8;

  /// `rounded-md` — inputs and small chips.
  static const double input = 8;

  /// A pill: status chips, badges.
  static const double pill = 999;

  static const double sheet = 16;
}

class AppStroke {
  const AppStroke._();

  /// A hairline. Stays 1 logical pixel everywhere — the web's `1px solid`.
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

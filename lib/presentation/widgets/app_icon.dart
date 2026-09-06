import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme/app_colors.dart';

/// The app's icons, taken from the web's own set.
///
/// `src/components/ui/icons.tsx` holds 54 hand-rolled Heroicons v1 outline
/// glyphs with no library dependency. Every one has the same shape — a single
/// `d` path on a 24×24 viewBox, `fill="none"`, `stroke="currentColor"`,
/// `strokeWidth={2}`, round caps and joins — so the path data is stored here
/// verbatim and stroked with those settings. Copy the `d` string across
/// unchanged; do not redraw an icon by eye.
///
/// Replacing Material's icon set is one of the four levers that stop the app
/// reading as Android (brief §15). Add glyphs here as screens need them rather
/// than porting all 54 up front.
class AppIcons {
  const AppIcons._();

  /// `BoxIcon` — products.
  static const box = <String>[
    'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4',
  ];

  /// `ShoppingCartIcon` — orders and carts.
  static const shoppingCart = <String>[
    'M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 '
        '1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 '
        '0 014 0z',
  ];

  /// `HistoryIcon` — stock movements.
  static const history = <String>[
    'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
  ];

  /// `TruckIcon` — purchases and deliveries. Two paths in the source.
  static const truck = <String>[
    'M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z',
    'M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4'
        '-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 '
        '1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 '
        '2 0 104 0m-4 0a2 2 0 114 0',
  ];

  /// `DollarIcon` — sales and money.
  static const dollar = <String>[
    'M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 '
        '2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 '
        '9 0 11-18 0 9 9 0 0118 0z',
  ];

  /// The arrow the web renders on its own back-to-login link — an arrow with
  /// a shaft, not `ChevronLeftIcon`. Taken from src/app/forgot-password/page.tsx.
  ///
  /// The Figma frames still show a typographic "←" here; those two frames were
  /// drawn before the icon set was imported, so the glyph is a leftover
  /// stand-in rather than the intent.
  static const arrowLeft = <String>[
    'M10 19l-7-7m0 0l7-7m-7 7h18',
  ];

  /// `LogoutIcon` — ending the session.
  static const logout = <String>[
    'M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 '
        '3 0 013 3v1',
  ];

  /// `ClipboardIcon` — orders awaiting action.
  static const clipboard = <String>[
    'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 '
        '2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h'
        '.01M9 16h.01',
  ];
}

/// Draws one of [AppIcons] at [size], in [color].
///
/// Defaults to `text/muted`: the web's icons are overwhelmingly zinc, and
/// colour appears in only six places, where it marks a category rather than
/// decorating. Pass one of the `AppColors.accent*` values for those.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.paths, {
    super.key,
    this.size = 24,
    this.color = AppColors.textMuted,
    this.strokeWidth = 2,
  });

  /// A glyph from [AppIcons]. A list because some of the source icons — the
  /// truck, for one — are drawn with more than one `d` path.
  final List<String> paths;

  final double size;
  final Color color;

  /// In the source 24-unit space, scaled with [size] — so a 16px icon keeps
  /// the same visual weight as a 24px one rather than looking heavier.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _IconPainter(
            paths: _parse(paths),
            color: color,
            strokeWidth: strokeWidth,
          ),
        ),
      );

  /// Parsed paths are cached: the same glyph appears many times in a list, and
  /// re-parsing its `d` string on every build is wasted work on a low-end
  /// handset.
  static final _cache = <String, List<Path>>{};

  static List<Path> _parse(List<String> data) =>
      _cache[data.join()] ??= data.map(parseSvgPathData).toList(growable: false);
}

class _IconPainter extends CustomPainter {
  const _IconPainter({
    required this.paths,
    required this.color,
    required this.strokeWidth,
  });

  /// The source viewBox. Every icon in `icons.tsx` is authored on it.
  static const double _viewBox = 24;

  final List<Path> paths;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..scale(scale);
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) =>
      oldDelegate.paths != paths ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

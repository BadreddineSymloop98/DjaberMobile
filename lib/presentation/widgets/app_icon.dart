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

  /// `BoltIcon` — the advanced stock mode, and anything "powered up".
  static const bolt = <String>[
    'M13 10V3L4 14h7v7l9-11h-7z',
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

  /// A bare tick. **The one glyph not in the web's set** — `icons.tsx` has
  /// `CheckCircleIcon` but no plain check, so this is the Heroicons v1 outline
  /// check from the same family the rest of the set is drawn from.
  static const check = <String>[
    'M5 13l4 4L19 7',
  ];

  /// `FacebookIcon` — **filled**, not stroked. Pass `filled: true`.
  static const facebook = <String>[
    'M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 '
        '10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 '
        '4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 '
        '0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 '
        '23.027 24 18.062 24 12.073z',
  ];

  /// `InstagramIcon` — **filled**, not stroked. Pass `filled: true`.
  static const instagram = <String>[
    'M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 '
        '4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 '
        '4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-'
        '3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-'
        '1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 '
        '1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 '
        '0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 '
        '0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 '
        '23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 '
        '6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-'
        '3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 '
        '0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 '
        '000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 '
        '100 2.881 1.44 1.44 0 000-2.881z',
  ];

  /// `CloseIcon` — dismissing a sheet or a web view.
  static const close = <String>[
    'M6 18L18 6M6 6l12 12',
  ];

  /// `GlobeIcon` — the host shown in the web view's address pill.
  static const globe = <String>[
    'M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 '
        '2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 '
        '20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
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
    this.filled = false,
  });

  /// A glyph from [AppIcons]. A list because some of the source icons — the
  /// truck, for one — are drawn with more than one `d` path.
  final List<String> paths;

  final double size;
  final Color color;

  /// In the source 24-unit space, scaled with [size] — so a 16px icon keeps
  /// the same visual weight as a 24px one rather than looking heavier.
  final double strokeWidth;

  /// Filled rather than stroked. The brand marks — Facebook and Instagram —
  /// are authored `fill="currentColor"` in `icons.tsx`; everything else in
  /// the set is `fill="none"` with a stroke.
  final bool filled;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _IconPainter(
            paths: _parse(paths),
            color: color,
            strokeWidth: strokeWidth,
            filled: filled,
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
    required this.filled,
  });

  /// The source viewBox. Every icon in `icons.tsx` is authored on it.
  static const double _viewBox = 24;

  final List<Path> paths;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final paint = Paint()
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
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
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.filled != filled;
}

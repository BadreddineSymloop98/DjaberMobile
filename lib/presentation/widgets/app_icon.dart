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
  static const box =
      'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4';

  /// `ShoppingCartIcon` — orders and carts.
  static const shoppingCart = 'M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 '
      '2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 '
      '2 0 11-4 0 2 2 0 014 0z';

  /// `HistoryIcon` — stock movements.
  static const history = 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z';
}

/// Draws one of [AppIcons] at [size], in [color].
///
/// Defaults to `text/muted`: the web's icons are overwhelmingly zinc, and
/// colour appears in only six places, where it marks a category rather than
/// decorating. Pass one of the `AppColors.accent*` values for those.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.path, {
    super.key,
    this.size = 24,
    this.color = AppColors.textMuted,
    this.strokeWidth = 2,
  });

  /// A `d` string from [AppIcons].
  final String path;

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
            path: _parse(path),
            color: color,
            strokeWidth: strokeWidth,
          ),
        ),
      );

  /// Parsed paths are cached: the same glyph appears many times in a list, and
  /// re-parsing its `d` string on every build is wasted work on a low-end
  /// handset.
  static final _cache = <String, Path>{};

  static Path _parse(String data) =>
      _cache[data] ??= parseSvgPathData(data);
}

class _IconPainter extends CustomPainter {
  const _IconPainter({
    required this.path,
    required this.color,
    required this.strokeWidth,
  });

  /// The source viewBox. Every icon in `icons.tsx` is authored on it.
  static const double _viewBox = 24;

  final Path path;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas
      ..save()
      ..scale(scale);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) =>
      oldDelegate.path != path ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

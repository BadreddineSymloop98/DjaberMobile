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

  /// `MenuIcon` — the tier-3 drawer (brief §16).
  static const menu = <String>[
    'M4 6h16M4 12h16M4 18h16',
  ];

  /// `ChevronRightIcon` — onwards. Flip it under RTL.
  static const chevronRight = <String>[
    'M9 5l7 7-7 7',
  ];

  /// `HomeIcon` — the first bottom-nav destination.
  static const home = <String>[
    'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 '
        '01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 '
        '1m-6 0h6',
  ];

  /// `BellIcon` — the escalation queue, `File`.
  static const bell = <String>[
    'M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 '
        '00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 '
        '.538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9',
  ];

  /// `ChatIcon` — conversations, and the connected-pages KPI.
  static const chat = <String>[
    'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 '
        '01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 '
        '4.03-8 9-8s9 3.582 9 8z',
  ];

  /// `SparklesIcon` — the AI agent.
  static const sparkles = <String>[
    'M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846'
        '-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 '
        '3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 '
        '9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a'
        '3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.455 '
        '2.456L21.75 6l-1.036.259a3.375 3.375 0 00-2.455 2.456zM16.894 '
        '20.567L16.5 21.75l-.394-1.183a2.25 2.25 0 00-1.423-1.423L13.5 '
        '18.75l1.183-.394a2.25 2.25 0 001.423-1.423l.394-1.183.394 1.183a2.25 '
        '2.25 0 001.423 1.423l1.183.394-1.183.394a2.25 2.25 0 00-1.423 1.423z',
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

  // ---- Added for `09a — Menu`, the tier-3 drawer ----

  /// `MessageIcon` — Réseaux sociaux. Distinct from [chat]: this is the
  /// squared speech bubble the web uses for a channel, not a conversation.
  static const message = <String>[
    'M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 '
        '012 2v8a2 2 0 01-2 2h-5l-5 5v-5z',
  ];

  /// `GridIcon` — the Services group.
  static const grid = <String>[
    'M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm10 0a2 2 '
        '0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 '
        '012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zm10 0a2 2 0 '
        '012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z',
  ];

  /// `ChartIcon` — Analyses. Stays muted: analytics live on the web.
  static const chart = <String>[
    'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 '
        '2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 '
        '012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z',
  ];

  /// `FileTextIcon` — Rapports. Also muted, for the same reason.
  static const fileText = <String>[
    'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 '
        '01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
  ];

  /// `SettingsIcon` — Paramètres. Two paths: the cog and its centre.
  static const settings = <String>[
    'M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 '
        '1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 '
        '2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 '
        '2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 '
        '1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 '
        '00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 '
        '00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 '
        '001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 '
        '2.572-1.065z',
    'M15 12a3 3 0 11-6 0 3 3 0 016 0z',
  ];

  /// `ChevronDownIcon` — an expanded menu group. Never mirrored under RTL:
  /// down is down in every reading direction.
  static const chevronDown = <String>[
    'M19 9l-7 7-7-7',
  ];

  /// `BotIcon` — the AI agents subrow. Heroicons v2 in the source, unlike the
  /// rest of the set, which is why it carries far more path than its
  /// neighbours.
  static const bot = <String>[
    'M9.75 3.104v5.714a2.25 2.25 0 01-.659 1.591L5 14.5M9.75 '
        '3.104c-.251.023-.501.05-.75.082m.75-.082a24.301 24.301 0 014.5 0m0 '
        '0v5.714a2.25 2.25 0 00.659 1.591L19 14.5M14.25 3.104c.251.023.501.05.75'
        '.082M19 14.5a2.25 2.25 0 00.75-1.661V8.706c0-.248-.034-.495-.1-.736M19 '
        '14.5l-1.5 1.5M5 14.5a2.25 2.25 0 01-.75-1.661V8.706c0-.248.034-.495.1-'
        '.736M5 14.5l1.5 1.5m0 0l.75.75M6.5 16l-.75.75M17.5 16l.75.75M17.5 '
        '16l-.75.75M12 21a2.25 2.25 0 002.25-2.25V17.5m-4.5 0v1.25A2.25 2.25 0 '
        '0012 21m0 0a2.25 2.25 0 002.25-2.25M12 21a2.25 2.25 0 01-2.25-2.25',
  ];

  /// `MegaphoneIcon` — the Commercial subrow, which is `BIENTÔT`.
  static const megaphone = <String>[
    'M10.34 15.84c-.688-.06-1.386-.09-2.09-.09H7.5a4.5 4.5 0 110-9h.75c.704 0 '
        '1.402-.03 2.09-.09m0 9.18c.253.962.584 1.892.985 2.783.247.55.06 1.21'
        '-.463 1.511l-.657.38c-.551.318-1.26.117-1.527-.461a20.845 20.845 0 '
        '01-1.44-4.282m3.102.069a18.03 18.03 0 01-.59-4.59c0-1.586.205-3.124.59'
        '-4.59m0 9.18a23.848 23.848 0 018.835 2.535M10.34 6.66a23.847 23.847 0 '
        '008.835-2.535m0 0A23.74 23.74 0 0018.795 3m.38 1.125a23.91 23.91 0 '
        '011.014 5.395m-1.014 8.855c-.118.38-.245.754-.38 1.125m.38-1.125a23.91 '
        '23.91 0 001.014-5.395m0-3.46c.495.413.811 1.035.811 1.73 0 .695-.316 '
        '1.317-.811 1.73m0-3.46a24.347 24.347 0 010 3.46',
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

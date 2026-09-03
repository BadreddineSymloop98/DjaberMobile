import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The Djaber lockup: the network mark, the wordmark, and an optional tagline.
///
/// Geometry is a direct transcription of the SVG in `src/components/Header.tsx`,
/// which the web renders in five places and which the brief settled as
/// canonical over the logo PNG on the desktop. Do not redraw it from an image.
///
/// The mark is a small network graph — a circle holding three bright nodes and
/// one dim one — which reads as "agent" in a way a letterform does not, and
/// being circular it does not compete with the square menu button beside it.
class DjaberLogo extends StatelessWidget {
  const DjaberLogo({
    super.key,
    this.size = 40,
    this.showWordmark = true,
    this.showTagline = false,
    this.gap = AppSpacing.md,
  });

  /// Width and height of the mark. The wordmark scales with it, keeping the
  /// web's 40px mark / 20px wordmark ratio.
  final double size;

  final bool showWordmark;

  /// The tagline is brand copy (`dash.tagline` in `src/lib/i18n.ts`), not part
  /// of the lockup. Off in headers, on where the brand is introduced.
  final bool showTagline;

  /// Space between the mark and the wordmark.
  final double gap;

  @override
  Widget build(BuildContext context) {
    final mark = DjaberMark(size: size);
    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            SizedBox(width: gap),
            DjaberWordmark(fontSize: size / 2),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: size * 0.35),
          Text(L10n.of(context).appTagline, style: AppText.label),
        ],
      ],
    );
  }
}

/// *Djaber* in primary, *.ai* in secondary — the web's own split treatment.
/// Syne Bold with −2% tracking, matching `text-xl font-bold tracking-tight`.
class DjaberWordmark extends StatelessWidget {
  const DjaberWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: AppFonts.display,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: fontSize * -0.02,
      height: 1.1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Djaber',
            style: base.copyWith(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: '.ai',
            style: base.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      // The wordmark is a name, never mirrored for Arabic.
      textDirection: TextDirection.ltr,
    );
  }
}

/// The 40×40 mark on its own.
class DjaberMark extends StatelessWidget {
  const DjaberMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MarkPainter()),
      );
}

class _MarkPainter extends CustomPainter {
  /// The source SVG's coordinate space. Every value below is in these units
  /// and is scaled to the requested size, so the mark stays exact at 40px in a
  /// header and at 96px on the splash.
  static const double _viewBox = 40;

  /// `#a1a1aa` — zinc-400, the literal in the SVG. Kept as the artwork's own
  /// value rather than remapped onto a text token, since it is the second stop
  /// of a gradient, not type.
  static const Color _dim = Color(0xFFA1A1AA);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _viewBox;
    Offset p(double x, double y) => Offset(x * k, y * k);

    // Outer ring — white → #a1a1aa along the 0,0 → 40,40 diagonal.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * k
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), _dim],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(p(20, 20), 18 * k, ring);

    // Connections, drawn under the nodes so the joins are covered.
    final linkBright = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * k
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6);
    final linkDim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * k
      ..color = _dim.withValues(alpha: 0.6);

    canvas.drawLine(p(20, 15), p(14, 22), linkBright);
    canvas.drawLine(p(20, 15), p(26, 22), linkBright);
    canvas.drawLine(p(14, 25), p(20, 28), linkDim);
    canvas.drawLine(p(26, 25), p(20, 28), linkDim);

    // Nodes — three bright, one dim.
    final bright = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(p(20, 12), 3 * k, bright);
    canvas.drawCircle(p(12, 24), 3 * k, bright);
    canvas.drawCircle(p(28, 24), 3 * k, bright);
    canvas.drawCircle(p(20, 28), 2 * k, Paint()..color = _dim);
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}

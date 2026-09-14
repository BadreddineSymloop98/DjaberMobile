import 'package:flutter/widgets.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The Figma `Checklist Row` component (node `133:761`), and the hairline box
/// the rows sit in.
///
/// The component's own description: *"One step of the Démarrer checklist. Done
/// is struck through with a filled tick; Todo carries its step number in a
/// hairline ring."*
///
/// Both states are built: **Todo** carries its step number in a hairline ring
/// (`T1a`–`T1c`), **Done** a filled white tick and a subtitle saying what was
/// actually created (`T6 — Prêt`).
///
/// > The component's description says Done is *"struck through"*. The `T6`
/// > frame does not strike anything through — it swaps the ring for a filled
/// > tick and adds the subtitle. The frame is what is built here; the
/// > description is stale.
class ChecklistRow extends StatelessWidget {
  const ChecklistRow({
    super.key,
    required this.step,
    required this.label,
    this.dimmed = false,
    this.done = false,
    this.subtitle,
  });

  /// The step number shown inside the ring. Rendered as given — not derived
  /// from a list index, because a page may show a subset.
  ///
  /// Ignored when [done], which shows a tick instead.
  final int step;

  final String label;

  /// Ticked: a filled bullet rather than a numbered ring.
  final bool done;

  /// What the step actually produced — a product name, an agent and its tone.
  /// Only `T6` sets it.
  final String? subtitle;

  /// Steps this page is not about drop to 28% rather than being hidden, so the
  /// whole four-step shape stays visible while one part of it is emphasised.
  /// The value is the frames' own `opacity-28`.
  final bool dimmed;

  /// The dimmed opacity, from the tutorial frames.
  static const double dimOpacity = 0.28;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bullet(step: step, done: done),
        SizedBox(width: 2.56.w), // 10
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.title),
              if (subtitle != null) ...[
                SizedBox(height: AppSpacing.xxs), // 2
                Text(
                  subtitle!,
                  // `text/muted`, not the secondary the rest of the app uses
                  // for a second line: the frame holds it back so the step
                  // name stays the thing being read.
                  style: AppText.bodyS.copyWith(
                    height: 1.32,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md), // 12
      child: dimmed ? Opacity(opacity: dimOpacity, child: row) : row,
    );
  }
}

/// The step number in a hairline ring, or a filled tick once done — 20x20,
/// fully rounded either way.
class _Bullet extends StatelessWidget {
  const _Bullet({required this.step, required this.done});

  final int step;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.13.w, // 20
      height: 5.13.w, // 20
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? AppColors.textPrimary : null,
        border: done
            ? null
            : Border.all(
                color: AppColors.rule,
                width: AppStroke.hairline,
              ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      // Forced LTR: a step number is a numeral, and the frames keep numerals
      // in reading order under RTL rather than mirroring them (brief §21.8).
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: done
            ? Text(
                '✓',
                style: AppText.labelMicro.copyWith(color: AppColors.ink),
              )
            : Text('$step', style: AppText.labelMicro),
      ),
    );
  }
}

/// The card the rows sit in: one surface, a hairline border, and a hairline
/// between each pair of rows.
class ChecklistBox extends StatelessWidget {
  const ChecklistBox({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(
          Container(height: AppStroke.hairline, color: AppColors.rule),
        );
      }
      children.add(rows[i]);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

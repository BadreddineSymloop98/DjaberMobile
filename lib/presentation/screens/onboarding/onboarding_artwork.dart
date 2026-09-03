import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/djaber_logo.dart';

/// The artwork for the three onboarding slides.
///
/// Real UI rather than illustration, following the Figma frames: the promise on
/// screen is the product on screen. These are **stand-ins built from the same
/// tokens**, not the real components — the Escalation Card, List Row and
/// Shortcut Tile do not exist in code yet. When they do, replace the bodies
/// here with instances of them and delete the private widgets at the bottom of
/// this file.
///
/// Nothing here is interactive, and every string is a placeholder from the
/// `onboardingSample*` keys, not live data.

/// Slide 1 — the agent answering a customer.
class ConversationArtwork extends StatelessWidget {
  const ConversationArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return _Frame(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThreadHeader(name: l10n.onboardingSampleCustomer),
          const SizedBox(height: AppSpacing.lg),
          _Bubble(text: l10n.onboardingSampleMessage, fromCustomer: true),
          const SizedBox(height: AppSpacing.sm),
          _Bubble(text: l10n.onboardingSampleReply, fromCustomer: false),
          const SizedBox(height: AppSpacing.md),
          _LiveChip(label: l10n.onboardingSampleHandling),
        ],
      ),
    );
  }
}

/// Slide 2 — the escalation card, which is the whole reason the app exists.
class EscalationArtwork extends StatelessWidget {
  const EscalationArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return _Frame(
      // The waiting state takes the strong rule and primary-weight label; the
      // handled state takes the hairline and muted text. That is the web's own
      // mechanism (`--rule` versus `--rule-strong`) doing the work depth used
      // to do before the flat decision.
      border: AppColors.ruleStrong,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Dot(color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.onboardingSampleNeedsHuman.toUpperCase(),
                style: AppText.label.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.onboardingSampleCustomer, style: AppText.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.onboardingSampleEscalation,
            style: AppText.bodyS,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Slide 3 — a row of shortcut tiles, standing for the stock modules.
class ShortcutsArtwork extends StatelessWidget {
  const ShortcutsArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    // Accents are the web's own six, used the way the web uses them: colour
    // marks a category, never decoration.
    final tiles = [
      (l10n.onboardingShortcutProducts, AppColors.textMuted),
      (l10n.onboardingShortcutOrders, AppColors.accentOrders),
      (l10n.onboardingShortcutMovements, AppColors.accentInbound),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        children: [
          for (final (index, (label, accent)) in tiles.indexed) ...[
            // Flexible rather than a fixed width, so three tiles still fit
            // inside the gutters on a 320dp handset.
            Expanded(child: _ShortcutTile(label: label, accent: accent)),
            if (index < tiles.length - 1) const SizedBox(width: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stand-ins. Delete once the real components land.
// ---------------------------------------------------------------------------

/// A surface with a hairline — the shape every card in the app takes.
class _Frame extends StatelessWidget {
  const _Frame({required this.child, this.border = AppColors.rule});

  final Widget child;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fills the gutters on a phone but stops growing on a tablet. A fixed
      // width would overflow a 320dp handset, which is inside the range this
      // market actually ships on.
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(AppSpacing.gutterTight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DjaberMark(size: 22),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(name, style: AppText.title)),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromCustomer});

  final String text;
  final bool fromCustomer;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromCustomer
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: fromCustomer ? AppColors.surfaceHigh : AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Text(
          text,
          style: AppText.bodyS.copyWith(
            color: fromCustomer ? AppColors.textPrimary : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// The web's `.status-live` pill, minus the pulse.
class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Dot(color: AppColors.live),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label.toUpperCase(),
            style: AppText.labelS.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stands in for an Icon/* component. The real set is the web's 54
          // hand-rolled Heroicons in src/components/ui/icons.tsx.
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              border: Border.all(color: accent, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            label,
            style: AppText.labelS.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

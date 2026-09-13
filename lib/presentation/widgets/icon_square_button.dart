import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';

/// A 40×40 boxed icon control — the shape `Menu Button` (node `31:11`) already
/// used, generalised when `17 — Produits` and `18 — Ajouter un produit`
/// arrived with a back button drawn identically.
///
/// The border is `line/edge` (12% white), the one token in the file with no
/// palette entry (brief §21.9). It sits between `line/hairline` and
/// `line/lit`, and it is inlined here rather than invented as a colour
/// constant because this is still the only place the design uses it.
class IconSquareButton extends StatelessWidget {
  const IconSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    this.flipInRtl = false,
    this.color = AppColors.textPrimary,
  });

  final List<String> icon;
  final VoidCallback onTap;

  /// Read out by TalkBack. Required in practice for an icon-only control —
  /// without it the button announces itself as just "button".
  final String? semanticLabel;

  /// Set for a glyph whose meaning is directional. A back arrow points
  /// whichever way back is, so it follows the layout; a logo or a bell does
  /// not.
  final bool flipInRtl;

  final Color color;

  @override
  Widget build(BuildContext context) {
    final glyph = AppIcon(icon, size: 6.15.w /* 24 */, color: color);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm), // 8
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: const Color(0x1FFFFFFF), // line/edge, 12%
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: flipInRtl
              ? Transform.flip(
                  flipX: Directionality.of(context) == TextDirection.rtl,
                  child: glyph,
                )
              : glyph,
        ),
      ),
    );
  }
}

/// The back control at the top of a pushed screen.
///
/// Pops when there is something to pop and falls back to [fallback]
/// otherwise. That second half is load-bearing in this app: navigation uses
/// `go`, which *replaces*, so a screen opened from the drawer has an empty
/// stack and a bare `pop()` would reach Android and close the app — the same
/// failure `ExitGuard` exists to soften.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onBack,
    this.semanticLabel,
  });

  final VoidCallback onBack;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => IconSquareButton(
        icon: AppIcons.arrowLeft,
        onTap: onBack,
        semanticLabel: semanticLabel,
        flipInRtl: true,
      );
}

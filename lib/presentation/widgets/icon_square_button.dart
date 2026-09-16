import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';
import 'back_scope.dart';

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

/// The back control at the top of a screen.
///
/// By default it runs [BackScope.back], **the same path as Android back**: it
/// pops what is below, asks first if the screen has unsaved work, and
/// otherwise goes to the parent that `router.dart` declares for the route.
/// A screen therefore never writes its own "pop or go" logic, and the arrow
/// and the system button cannot disagree. Pass [onBack] only for a control
/// that means something else.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onBack,
    this.semanticLabel,
  });

  final VoidCallback? onBack;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => IconSquareButton(
        icon: AppIcons.arrowLeft,
        onTap: onBack ?? () => BackScope.back(context),
        semanticLabel: semanticLabel,
        flipInRtl: true,
      );
}

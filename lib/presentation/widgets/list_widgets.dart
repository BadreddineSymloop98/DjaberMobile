import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

// Pieces shared by the list screens built from the same Figma pattern —
// Clients and Suppliers: two KPI tiles side by side, the initials square, the
// row's edit / delete glyphs, the Filtres and date chips, and the empty box.

/// Two tiles side by side at the height of the taller one.
class KpiPair extends StatelessWidget {
  const KpiPair(this.first, this.second, {super.key});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: second),
        ],
      ),
    );
  }
}

/// The 36px initials square — `ink/3` with a hairline, square as the file's
/// frozen style has it (the web's are round).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9.23.w, // 36
      height: 9.23.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(initials, style: AppText.title.copyWith(color: AppColors.textSecondary)),
    );
  }
}

/// A 16px glyph with a comfortable hit target.
class RowAction extends StatelessWidget {
  const RowAction({super.key, required this.icon, required this.label, required this.onTap});

  final List<String> icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(1.54.w),
          child: AppIcon(icon, size: 4.1.w, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

/// The file's `Tab` with a leading icon — *Filtres* and the date chips. Filled
/// white once it holds a value; a date chip then carries a × that clears it,
/// as the web's DatePicker does.
class ToolChip extends StatelessWidget {
  const ToolChip({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
    this.clearLabel,
  });

  final List<String> icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? clearLabel;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.ink : AppColors.textSecondary;
    return Container(
      decoration: BoxDecoration(
        color: active ? AppColors.textPrimary : Colors.transparent,
        border: Border.all(color: active ? AppColors.textPrimary : AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  onClear == null ? AppSpacing.md : AppSpacing.xs,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(icon, size: 3.59.w, color: fg),
                    SizedBox(width: 1.54.w),
                    Text(label, style: AppText.bodyS.copyWith(color: fg)),
                  ],
                ),
              ),
            ),
          ),
          if (onClear != null)
            Semantics(
              button: true,
              label: clearLabel,
              child: GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.xs, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                  child: AppIcon(AppIcons.close, size: 3.08.w, color: fg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The empty box — an icon, a title, a sentence.
class EmptyBox extends StatelessWidget {
  const EmptyBox({super.key, required this.icon, required this.title, required this.body});

  final List<String> icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 12.31.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          AppIcon(icon, size: 8.21.w, color: AppColors.textMuted),
          SizedBox(height: AppSpacing.md),
          Text(title, style: AppText.title, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

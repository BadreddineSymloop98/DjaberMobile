import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The one "leave without saving?" sheet, first drawn for `15c.2` and now used
/// by every screen whose back would throw work away.
///
/// The title and both buttons keep the agent form's approved copy
/// (`agentFormLeaveTitle`, `agentFormKeepEditing`, `agentFormLeave`) instead of
/// renaming it to common keys, which would send approved fr/ar strings back
/// for review. Only [body] changes per screen. [title] is for the one case
/// where "without saving" is wrong: an unfinished payment.
///
/// Resolves true only on an explicit Leave. Dismissing the sheet is "keep
/// editing".
Future<bool> showLeaveSheet(
  BuildContext context, {
  required String body,
  String? title,
}) {
  final l10n = L10n.of(context);
  return showConfirmSheet(
    context,
    title: title ?? l10n.agentFormLeaveTitle,
    body: body,
    // The safe answer is the loud one, and it is what dismissing the sheet
    // means too.
    dismissLabel: l10n.agentFormKeepEditing,
    confirmLabel: l10n.agentFormLeave,
  );
}

/// The **destructive** confirmation — `14d`'s sheet, which the Figma reuses for
/// *Supprimer le produit*: title, one sentence, a filled red button, then an
/// outlined *Annuler*.
///
/// Distinct from [showConfirmSheet] on purpose. There the safe answer is the
/// loud one, because the question is "do you want to throw work away?". Here
/// the merchant came to delete, so the delete is the filled button — and it is
/// red, which is the whole reason this shape exists rather than the other.
///
/// Resolves true only on an explicit confirm.
///
/// [noticeTitle] / [noticeBody] add the boxed consequence the category delete
/// frame draws under the question — *"Cette catégorie contient 12 produits.
/// Ils n'auront plus de catégorie."* Shown only when a title is given.
Future<bool> showDestructiveSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? noticeTitle,
  String? noticeBody,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    builder: (sheet) {
      final l10n = L10n.of(sheet);
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xl,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.title),
              SizedBox(height: AppSpacing.xs),
              Text(
                body,
                style: AppText.bodyS.copyWith(
                  color: AppColors.textMuted,
                  height: 1.32,
                ),
              ),
              if (noticeTitle != null) ...[
                SizedBox(height: AppSpacing.xl),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(noticeTitle, style: AppText.title),
                      if (noticeBody != null) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          noticeBody,
                          style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xl),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentAlert,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(sheet).pop(true),
                child: Text(confirmLabel),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(sheet).pop(false),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}

/// The same sheet with its own words, for a question that is not "leave
/// without saving?".
///
/// Used by the edit form before a save that would delete variants: the red
/// button there has to say *Supprimer et enregistrer*, not *Quitter*.
///
/// Resolves true only on an explicit tap of [confirmLabel]; dismissing the
/// sheet is the safe answer.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String dismissLabel,
  required String confirmLabel,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xl, AppSpacing.gutter, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppText.title),
            SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(sheet).pop(false),
              child: Text(dismissLabel),
            ),
            SizedBox(height: AppSpacing.sm),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.accentAlert),
              onPressed: () => Navigator.of(sheet).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

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
}) async {
  final l10n = L10n.of(context);
  final leave = await showModalBottomSheet<bool>(
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
            Text(title ?? l10n.agentFormLeaveTitle, style: AppText.title),
            SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(sheet).pop(false),
              child: Text(l10n.agentFormKeepEditing),
            ),
            SizedBox(height: AppSpacing.sm),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.accentAlert),
              onPressed: () => Navigator.of(sheet).pop(true),
              child: Text(l10n.agentFormLeave),
            ),
          ],
        ),
      ),
    ),
  );
  return leave ?? false;
}

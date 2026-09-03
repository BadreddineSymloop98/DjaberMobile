import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/extensions/responsive_extension.dart';
import '../../core/utils/validators.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The Text Field component from Figma (`36:5`).
///
/// Structure, from the frame: an uppercase mono label with an optional inline
/// action on the right, a flat `ink/surface` input with a hairline border and
/// 8px radius, and an optional hint underneath.
///
/// **The error state is not in the design file** — the component has no error
/// variant. It is added here in the least invented way available: the message
/// takes the hint's slot, so the field does not change height when one
/// replaces the other, and the border switches to `accent/alert`. The message
/// itself uses the same style as the inline action (Geist Regular 11), which
/// is the design's existing small-text treatment, rather than the mono hint —
/// a full sentence in tracked 9px mono is not readable.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.hint,
    this.placeholder,
    this.errorText,
    this.action,
    this.onActionTap,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.onSubmitted,
  });

  /// Rendered uppercase, matching every other label in the app.
  final String label;

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Standing rule for the field, shown when there is no error.
  final String? hint;

  final String? placeholder;

  /// When non-null the field is in its error state.
  final String? errorText;

  /// Optional inline link on the label row.
  final String? action;
  final VoidCallback? onActionTap;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  bool get _hasError => errorText != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _LabelRow(
          label: label,
          action: action,
          onActionTap: onActionTap,
        ),
        SizedBox(height: 1.54.w), // 6
        _Input(
          controller: controller,
          focusNode: focusNode,
          placeholder: placeholder,
          hasError: _hasError,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
        ),
        if (_hasError || hint != null) ...[
          SizedBox(height: 1.54.w), // 6
          _Footnote(errorText: errorText, hint: hint),
        ],
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.label, this.action, this.onActionTap});

  final String label;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: AppText.labelMeta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              action!,
              style: AppText.actionS,
            ),
          ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.hasError,
    required this.keyboardType,
    required this.textInputAction,
    required this.inputFormatters,
    required this.obscureText,
    required this.textCapitalization,
    required this.autofillHints,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? placeholder;
  final bool hasError;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Repaints the border when focus changes, without making the whole
      // screen rebuild for it.
      animation: focusNode,
      builder: (context, _) {
        final Color border;
        if (hasError) {
          border = AppColors.accentAlert;
        } else if (focusNode.hasFocus) {
          border = AppColors.ruleStrong;
        } else {
          border = AppColors.rule;
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: border, width: AppStroke.hairline),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 0.6.h, // ~5 — the rest of the 12 comes from the field
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            obscureText: obscureText,
            textCapitalization: textCapitalization,
            autofillHints: autofillHints,
            onSubmitted: onSubmitted,
            style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
            cursorColor: AppColors.textPrimary,
            cursorWidth: 1.5,
            // The design's own input treatment is the container above; Material's
            // decoration would draw a second one on top of it.
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: placeholder,
              hintStyle: AppText.bodyS,
              filled: false,
            ),
          ),
        );
      },
    );
  }
}

/// The hint slot — carries the error when there is one, the standing rule
/// otherwise. Same slot for both so the field keeps its height.
class _Footnote extends StatelessWidget {
  const _Footnote({required this.errorText, required this.hint});

  final String? errorText;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    if (errorText != null) {
      return Text(
        errorText!,
        style: AppText.actionS.copyWith(color: AppColors.accentAlert),
      );
    }
    return Text(hint!.toUpperCase(), style: AppText.labelMeta);
  }
}

/// Maps a validation code to the message the web already uses.
///
/// Kept next to the field rather than in the validator so the rules stay pure
/// and the wording stays in one place.
String messageFor(FieldError error, AppFieldMessages messages) =>
    switch (error) {
      FieldError.required => messages.required,
      FieldError.invalidEmail => messages.invalidEmail,
      FieldError.tooShort => messages.tooShort,
    };

/// The three messages a field can show, supplied by the screen from `L10n`.
class AppFieldMessages {
  const AppFieldMessages({
    required this.required,
    required this.invalidEmail,
    required this.tooShort,
  });

  final String required;
  final String invalidEmail;
  final String tooShort;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/catalogue.dart';
import '../../../data/repositories/catalogue_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/categories_view_model.dart';
import '../../viewmodels/category_form_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';

/// `Add / edit a category` (Figma `629:7576` / `629:7842`) — the web's modal as
/// a sheet over the list.
///
/// *Nom \**, *Description*, *Couleur*: the ten presets as squares (the file's
/// frozen radius-8 style; the web draws circles) and a dashed **+** that opens
/// a custom hex, standing in for the web's `<input type="color">`.
///
/// Returns the saved category, or null when the sheet was dismissed.
Future<ProductCategory?> showCategoryFormSheet(
  BuildContext context, {
  required CatalogueRepository catalogue,
  required Set<String> knownNames,
  ProductCategory? editing,
}) {
  return showModalBottomSheet<ProductCategory>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _CategoryFormSheet(
      catalogue: catalogue,
      knownNames: knownNames,
      editing: editing,
    ),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({
    required this.catalogue,
    required this.knownNames,
    required this.editing,
  });

  final CatalogueRepository catalogue;
  final Set<String> knownNames;
  final ProductCategory? editing;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final CategoryFormViewModel _model = CategoryFormViewModel(
    catalogue: widget.catalogue,
    knownNames: widget.knownNames,
    editing: widget.editing,
  );

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await _model.save();
    if (saved == null || !mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _pickCustom() async {
    final picked = await showCustomColorSheet(context, initial: _model.color);
    if (picked != null) _model.setColor(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final nameError = switch (_model.visibleNameError) {
          null => null,
          CategoryNameError.required => l10n.productErrRequired,
          CategoryNameError.tooShort => l10n.categoryNameTooShort,
          CategoryNameError.duplicate => l10n.categoryNameTaken,
        };

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutterTight,
                AppSpacing.sm,
                AppSpacing.gutterTight,
                3.32.h, // 28
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _model.isEditing ? l10n.categoryEditTitle : l10n.categoryAddTitle,
                    style: AppText.title,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: l10n.categoryName,
                    isRequired: true,
                    controller: _model.name.controller,
                    focusNode: _model.name.focusNode,
                    placeholder: l10n.categoryNamePlaceholder,
                    errorText: nameError,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    // The backend's own ceiling on create.
                    inputFormatters: [LengthLimitingTextInputFormatter(255)],
                    onSubmitted: (_) => _model.description.focusNode.requestFocus(),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: l10n.productDescription,
                    controller: _model.description.controller,
                    focusNode: _model.description.focusNode,
                    placeholder: l10n.categoryDescriptionPlaceholder,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [LengthLimitingTextInputFormatter(5000)],
                    onSubmitted: (_) => _model.description.focusNode.unfocus(),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Text(l10n.categoryColor.toUpperCase(), style: AppText.labelMeta),
                  SizedBox(height: 1.54.w), // 6
                  ColorSwatchRow(
                    selected: {_model.color},
                    onTap: _model.isBusy ? null : _model.setColor,
                    customColor: _model.isCustomColor ? _model.color : null,
                    onCustom: _model.isBusy ? null : _pickCustom,
                    showCustom: true,
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  ApiErrorLine(error: _model.submitError),
                  FilledButton(
                    onPressed: _model.isBusy ? null : _save,
                    child: _model.isBusy
                        ? SizedBox.square(
                            dimension: AppSpacing.gutterTight,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.ink,
                            ),
                          )
                        : Text(_model.isEditing ? l10n.categoryUpdate : l10n.categoryCreate),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: _model.isBusy ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The ten presets as squares, optionally followed by the dashed **+**.
///
/// Used by the form (one colour selected, with the custom tile) and by the
/// filter sheet (several selected, no custom tile). Wraps rather than
/// scrolling, so a narrow screen or a large font puts the tail on a second
/// line instead of hiding it.
class ColorSwatchRow extends StatelessWidget {
  const ColorSwatchRow({
    super.key,
    required this.selected,
    required this.onTap,
    this.customColor,
    this.onCustom,
    this.showCustom = false,
  });

  /// Colours drawn as selected, `#RRGGBB` in capitals.
  final Set<String> selected;
  final ValueChanged<String>? onTap;

  /// A colour outside the presets, drawn inside the **+** tile as selected.
  final String? customColor;

  final VoidCallback? onCustom;

  /// Draws the **+** tile (the form); the filter sheet has none.
  final bool showCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    // Ten presets and the + fit one line at the design width: 28 each, 4 apart.
    final size = math.max(7.18.w, 26.0);

    return Wrap(
      spacing: 1.03.w, // 4
      runSpacing: AppSpacing.sm,
      children: [
        for (final hex in kCategoryPresetColors)
          _Swatch(
            size: size,
            color: categoryColor(hex),
            selected: selected.contains(hex),
            semanticLabel: hex,
            onTap: onTap == null ? null : () => onTap!(hex),
          ),
        if (showCustom)
          customColor != null
              ? _Swatch(
                  size: size,
                  color: categoryColor(customColor),
                  selected: true,
                  semanticLabel: l10n.categoryColorCustom,
                  onTap: onCustom,
                )
              : _AddSwatch(size: size, label: l10n.categoryColorCustom, onTap: onCustom),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.size,
    required this.color,
    required this.selected,
    required this.semanticLabel,
    required this.onTap,
  });

  final double size;
  final Color color;
  final bool selected;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.card * 0.75),
            // The frame's selected ring: white, 2px.
            border: selected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
          ),
        ),
      ),
    );
  }
}

/// The dashed **+** tile.
class _AddSwatch extends StatelessWidget {
  const _AddSwatch({required this.size, required this.label, required this.onTap});

  final double size;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: _DashedBorderPainter(radius: AppRadius.card * 0.75),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: AppIcon(AppIcons.plus, size: size * 0.5, color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
        Radius.circular(radius),
      ));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 3), paint);
        distance += 6;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.radius != radius;
}

/// A custom colour as a hex, with a live preview — the mobile stand-in for the
/// web's native colour input, which has no equivalent without a new package.
///
/// Returns `#RRGGBB` in capitals, or null.
Future<String?> showCustomColorSheet(BuildContext context, {required String initial}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _CustomColorSheet(initial: initial),
  );
}

class _CustomColorSheet extends StatefulWidget {
  const _CustomColorSheet({required this.initial});

  final String initial;

  @override
  State<_CustomColorSheet> createState() => _CustomColorSheetState();
}

class _CustomColorSheetState extends State<_CustomColorSheet> {
  late final _controller = TextEditingController(text: widget.initial.replaceFirst('#', ''));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final normalized = normalizeCategoryColor(_controller.text);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterTight,
            AppSpacing.sm,
            AppSpacing.gutterTight,
            3.32.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.categoryColorCustom, style: AppText.title),
              SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.categoryColorHex,
                      controller: _controller,
                      focusNode: _focus,
                      placeholder: 'EC4899',
                      errorText: _controller.text.isNotEmpty && normalized == null
                          ? l10n.categoryColorInvalid
                          : null,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onSubmitted: (_) {
                        if (normalized != null) Navigator.of(context).pop(normalized);
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    width: AppSize.control,
                    height: AppSize.control,
                    decoration: BoxDecoration(
                      color: normalized == null ? Colors.transparent : categoryColor(normalized),
                      border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: normalized == null ? null : () => Navigator.of(context).pop(normalized),
                child: Text(l10n.categoryColorApply),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

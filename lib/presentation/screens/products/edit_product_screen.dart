import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/extensions/responsive_extension.dart';

import '../../../data/repositories/catalogue_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/add_product_view_model.dart' show PhotoRejection;
import '../../viewmodels/edit_product_view_model.dart';
import '../../viewmodels/form_field_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../tutorial/tutorial_messages.dart';
import 'product_photo_picker.dart';

/// `Edit product` (Figma `619:6343`) — the web's Add/Edit product modal in its
/// edit mode.
///
/// It is `18 — Ajouter un produit` with four deliberate differences, all of
/// them in the frame and all of them forced by what the backend will accept:
///
/// - **No initial quantity.** `PUT /products/{id}` cannot carry one; stock
///   moves through *Ajuster le stock*. The field is not hidden, it is absent.
/// - **The prices are not marked required.** Update only asks for a
///   non-negative number, and the web's validator skips the required check
///   when editing. Selling ≥ cost is still enforced, as it is on the web.
/// - **A saved variant's quantity is locked**, at 40% as the frame draws it and
///   as the web disables it. The hint under the checkbox says where to change
///   it instead.
/// - **A + beside the unit picker** opens the web's *Add Custom Unit*, creates
///   the unit and selects it.
///
/// **One thing here is not on the web:** removing variants is confirmed. The
/// backend's variant delete is hard and writes off that variant's stock, and
/// unticking the box deletes every one of them — the web does it silently on
/// save. See [_confirmDestructive].
class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key, required this.productId});

  final String productId;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final EditProductViewModel _model = EditProductViewModel(
    products: context.read<ProductRepository>(),
    catalogue: context.read<CatalogueRepository>(),
    productId: widget.productId,
  );

  @override
  void initState() {
    super.initState();
    // No extra listener for the cost price here, unlike `18`: the base form
    // already notifies on every text change, and the selling price's validator
    // reads the cost field live — so a keystroke in one re-evaluates the other.
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _picking = false;

  Future<void> _pickPhotos() async {
    if (_picking) return;
    _picking = true;
    try {
      final picked = await pickProductPhotos(
        context,
        limit: _model.photoSlotsLeft,
      );
      if (picked.isEmpty || !mounted) return;

      final rejected = _model.addPhotos(picked);
      final l10n = L10n.of(context);
      if (rejected.contains(PhotoRejection.tooMany)) {
        AppToast.info(context, l10n.productPhotosTooMany);
      } else if (rejected.contains(PhotoRejection.tooLarge)) {
        AppToast.info(context, l10n.productPhotosTooLarge);
      } else if (rejected.contains(PhotoRejection.wrongType)) {
        AppToast.info(context, l10n.productPhotosWrongType);
      }
    } finally {
      _picking = false;
    }
  }

  /// Back on this form, through the route's [BackScope].
  ///
  /// Busy: ignored, so a save in flight is never orphaned. Saved (the photos
  /// failed and the screen stayed up): closes as a success, so the screens
  /// underneath refetch. Dirty: the leave sheet. Clean: the intercept is
  /// inactive and the navigator pops by itself.
  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (_model.isSaved) {
      _close();
      return false;
    }
    return showLeaveSheet(context, body: L10n.of(context).productEditLeaveBody);
  }

  /// `true` tells the detail screen and `17` to refetch. An explicit pop, so it
  /// bypasses the back intercept.
  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(Routes.productOf(widget.productId));
    }
  }

  Future<void> _save() async {
    // Validate first. Asking "3 variants will be permanently deleted" about a
    // form that then refuses to save — an empty name, say — frightens the
    // merchant over an action that was never going to run.
    if (!_model.validateForSave()) return;
    if (!await _confirmDestructive()) return;
    if (!mounted) return;

    final product = await _model.submitAndSave();
    if (product == null || !mounted) return;

    final l10n = L10n.of(context);
    if (_model.photosFailed) {
      AppToast.info(context, l10n.productPhotosUploadFailedEdit);
    } else {
      AppToast.success(context, l10n.toastProductUpdated);
    }
    _close();
  }

  /// Asks before a save that would destroy variants.
  ///
  /// **Not on the web**, which deletes on save without a word. The backend's
  /// delete is hard, and for a variant holding stock it also writes an
  /// adjustment of `-quantity` — so unticking a checkbox can take a product's
  /// whole stock off the books. The sheet names how many variants and how many
  /// units, and only then sends.
  ///
  /// True when there is nothing destructive to do, so the caller reads as
  /// "confirmed, go ahead".
  Future<bool> _confirmDestructive() async {
    final count = _model.variantsToDelete;
    if (count == 0) return true;

    final l10n = L10n.of(context);
    final stock = _model.stockToLose;
    // The destructive shape, the same one `Delete product` uses — one pattern
    // for every question whose yes destroys something.
    return showDestructiveSheet(
      context,
      title: l10n.productEditDeleteVariantsTitle,
      body: stock > 0
          ? l10n.productEditDeleteVariantsStock(count, stock)
          : l10n.productEditDeleteVariantsBody(count),
      confirmLabel: l10n.productEditDeleteVariantsConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    return ChangeNotifierProvider<EditProductViewModel>.value(
      value: _model,
      child: Consumer<EditProductViewModel>(
        builder: (context, model, _) {
          return BackIntercept(
            active: model.hasChanges || model.isBusy || model.isSaved,
            onBack: _onBack,
            child: Scaffold(
              backgroundColor: AppColors.ink,
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: gutter.copyWith(top: 0.47.h, bottom: AppSpacing.lg),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppBackButton(semanticLabel: l10n.commonBack),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: gutter.copyWith(bottom: AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.productEditTitle, style: AppText.displayM),
                            SizedBox(height: AppSpacing.xl),
                            if (model.isLoaded)
                              _Fields(
                                model: model,
                                onAddPhotos: _pickPhotos,
                                onAddUnit: () => _openNewUnitSheet(model),
                              )
                            else
                              _LoadingOrError(model: model),
                          ],
                        ),
                      ),
                    ),
                    if (model.isLoaded)
                      Padding(
                        padding: gutter.copyWith(top: AppSpacing.md, bottom: 3.32.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // The summary line. A 4xx that named inputs has
                            // already put its messages on those fields; this
                            // carries what the server says without blaming one
                            // — a duplicate SKU among them, which update
                            // reports as a 500.
                            ApiErrorLine(error: model.submitError),
                            FilledButton(
                              // Disabled in flight: a second tap would run the
                              // whole sequence again, and the deletes in it
                              // are not repeatable.
                              onPressed: model.isBusy ? null : _save,
                              child: model.isBusy
                                  ? SizedBox.square(
                                      dimension: AppSpacing.gutterTight,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.ink,
                                      ),
                                    )
                                  : Text(l10n.productEditSubmit),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The web's *Add Custom Unit* modal, as a sheet: name, abbreviation, create.
  Future<void> _openNewUnitSheet(EditProductViewModel model) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      isScrollControlled: true,
      builder: (sheet) => _NewUnitSheet(model: model),
    );
  }
}

/// The first load, or the failure that stopped it.
class _LoadingOrError extends StatelessWidget {
  const _LoadingOrError({required this.model});

  final EditProductViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    if (model.error == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: const Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ApiErrorLine(error: model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: model.load, child: Text(l10n.commonRetry)),
        ),
      ],
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({
    required this.model,
    required this.onAddPhotos,
    required this.onAddUnit,
  });

  final EditProductViewModel model;
  final VoidCallback onAddPhotos;
  final VoidCallback onAddUnit;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    // Our own validators first, then the server's — ours run on every
    // keystroke and describe what the merchant is fixing now, the server's
    // describe the state at the last submit.
    String? errorFor(FormFieldModel field, String apiName) {
      final local = model.visibleError(field);
      if (local != null) return tutorialFieldMessage(local, l10n);
      return model.serverFieldErrors[apiName];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.productName,
          isRequired: true,
          controller: model.name.controller,
          focusNode: model.name.focusNode,
          errorText: errorFor(model.name, 'name'),
          placeholder: l10n.productNamePlaceholder,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          // varchar(255), and exceeding it is a 500 on this route rather than
          // a 400 — capped at the keyboard, never sent long.
          inputFormatters: [LengthLimitingTextInputFormatter(255)],
          onSubmitted: (_) => model.sku.focusNode.requestFocus(),
        ),
        _gap,
        AppTextField(
          label: l10n.productSku,
          isRequired: true,
          controller: model.sku.controller,
          focusNode: model.sku.focusNode,
          errorText: errorFor(model.sku, 'sku'),
          placeholder: l10n.productSkuPlaceholder,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          inputFormatters: [LengthLimitingTextInputFormatter(255)],
          onSubmitted: (_) => model.description.focusNode.requestFocus(),
        ),
        _gap,
        AppTextField(
          label: l10n.productDescription,
          controller: model.description.controller,
          focusNode: model.description.focusNode,
          errorText: errorFor(model.description, 'description'),
          placeholder: l10n.productDescriptionPlaceholder,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          inputFormatters: [LengthLimitingTextInputFormatter(5000)],
          onSubmitted: (_) => model.costPrice.focusNode.requestFocus(),
        ),
        _gap,
        // Not marked required: update only asks for a non-negative number, and
        // the web's validator skips the required check when editing.
        AppTextField(
          label: l10n.productCostPrice,
          controller: model.costPrice.controller,
          focusNode: model.costPrice.focusNode,
          errorText: errorFor(model.costPrice, 'costPrice'),
          placeholder: '0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [_amountFormatter],
          onSubmitted: (_) => model.sellingPrice.focusNode.requestFocus(),
        ),
        _gap,
        AppTextField(
          label: l10n.productSellingPrice,
          controller: model.sellingPrice.controller,
          focusNode: model.sellingPrice.focusNode,
          errorText: errorFor(model.sellingPrice, 'sellingPrice'),
          placeholder: '0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [_amountFormatter],
          onSubmitted: (_) => model.minQuantity.focusNode.requestFocus(),
        ),
        _gap,
        AppTextField(
          label: l10n.productAlertThreshold,
          controller: model.minQuantity.controller,
          focusNode: model.minQuantity.focusNode,
          errorText: errorFor(model.minQuantity, 'minQuantity'),
          placeholder: '0',
          hint: l10n.productAlertThresholdHint,
          keyboardType: TextInputType.number,
          // The last keyboard field: the two below are pickers, so the action
          // closes the keyboard rather than promising a next field.
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          onSubmitted: (_) => model.minQuantity.focusNode.unfocus(),
        ),
        _gap,
        AppSelectField<String>(
          label: l10n.productCategory,
          placeholder: l10n.productCategoryNone,
          value: model.categoryId,
          onChanged: model.setCategory,
          enabled: model.categories.isNotEmpty,
          options: [
            // "None" first and always present: without it a category picked by
            // mistake could never be taken off again — and `""` is exactly
            // what the update route clears it with.
            SelectOption<String>(value: null, label: l10n.productCategoryNone),
            for (final category in model.categories)
              SelectOption<String>(
                value: category.id,
                label: category.name,
                meta: category.productCount == null
                    ? null
                    : l10n.productsCount(category.productCount!),
              ),
          ],
        ),
        _gap,
        _UnitRow(model: model, onAddUnit: onAddUnit),
        _gap,
        _Photos(model: model, onAdd: model.isBusy ? null : onAddPhotos),
        SizedBox(height: AppSpacing.lg),
        AppCheckbox(
          label: l10n.productHasVariants,
          // The frame's hint, which is the web's note: quantities are not
          // edited here.
          hint: l10n.productEditVariantsHint,
          value: model.hasVariants,
          onChanged: model.toggleHasVariants,
        ),
        if (model.hasVariants) ...[
          SizedBox(height: AppSpacing.lg),
          _VariantEditor(model: model),
        ],
      ],
    );
  }

  /// 14 between fields, from the frame.
  Widget get _gap => SizedBox(height: 3.59.w); // 14
}

/// The unit picker with the web's **+** beside it, which opens *Add Custom
/// Unit*. The frame draws the button 41×41 — one control height, square — so
/// it lines up with the field's input rather than with its label.
class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.model, required this.onAddUnit});

  final EditProductViewModel model;
  final VoidCallback onAddUnit;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppSelectField<String>(
            label: l10n.productUnit,
            placeholder: l10n.productUnitNone,
            value: model.unitId,
            onChanged: model.setUnit,
            options: [
              SelectOption<String>(value: null, label: l10n.productUnitNone),
              for (final unit in model.units)
                SelectOption<String>(value: unit.id, label: unit.label),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Semantics(
          button: true,
          label: l10n.productUnitAdd,
          child: GestureDetector(
            onTap: model.isBusy ? null : onAddUnit,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: AppSize.control,
              height: AppSize.control,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: AppIcon(AppIcons.plus, size: 3.59.w /* 14 */, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

/// *Add Custom Unit* — the web's small modal, as a sheet.
///
/// Both fields are required, as they are on the web and on the backend. A
/// duplicate name comes back as a 400 and is shown in place, with what was
/// typed still there.
class _NewUnitSheet extends StatefulWidget {
  const _NewUnitSheet({required this.model});

  final EditProductViewModel model;

  @override
  State<_NewUnitSheet> createState() => _NewUnitSheetState();
}

class _NewUnitSheetState extends State<_NewUnitSheet> {
  final _name = TextEditingController();
  final _abbreviation = TextEditingController();
  final _nameFocus = FocusNode();
  final _abbreviationFocus = FocusNode();

  bool _busy = false;
  bool _attempted = false;
  AppException? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(_refresh);
    _abbreviation.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _abbreviation.dispose();
    _nameFocus.dispose();
    _abbreviationFocus.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _attempted = true);
    if (_name.text.trim().isEmpty) {
      _nameFocus.requestFocus();
      return;
    }
    if (_abbreviation.text.trim().isEmpty) {
      _abbreviationFocus.requestFocus();
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await widget.model.createUnit(
      name: _name.text,
      abbreviation: _abbreviation.text,
    );
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _error = failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final required = l10n.productErrRequired;

    return SafeArea(
      child: Padding(
        // Lifts the sheet clear of the keyboard, which covers both fields on a
        // short handset otherwise.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
              Text(l10n.productUnitAdd, style: AppText.title),
              SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.productUnitName,
                isRequired: true,
                controller: _name,
                focusNode: _nameFocus,
                placeholder: l10n.productUnitNamePlaceholder,
                errorText: _attempted && _name.text.trim().isEmpty ? required : null,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(255)],
                onSubmitted: (_) => _abbreviationFocus.requestFocus(),
              ),
              SizedBox(height: 3.59.w),
              AppTextField(
                label: l10n.productUnitAbbreviation,
                isRequired: true,
                controller: _abbreviation,
                focusNode: _abbreviationFocus,
                placeholder: l10n.productUnitAbbreviationPlaceholder,
                errorText: _attempted && _abbreviation.text.trim().isEmpty ? required : null,
                textInputAction: TextInputAction.done,
                // The backend's own ceiling for this column.
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                onSubmitted: (_) => _create(),
              ),
              SizedBox(height: AppSpacing.lg),
              ApiErrorLine(error: _error),
              FilledButton(
                onPressed: _busy ? null : _create,
                child: _busy
                    ? SizedBox.square(
                        dimension: AppSpacing.gutterTight,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : Text(l10n.productUnitCreate),
              ),
              SizedBox(height: AppSpacing.sm),
              // Outlined, as the frame draws it — and as every other sheet in
              // the app pairs a primary action with its way out.
              OutlinedButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The photos box: the ones the product already has, then the add row.
///
/// The existing thumbnails are the web's, with one difference — the web's ✕
/// deletes server-side the moment it is tapped, while here the removal is
/// queued and only sent on save, so backing out of the screen changes nothing.
class _Photos extends StatelessWidget {
  const _Photos({required this.model, required this.onAdd});

  final EditProductViewModel model;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final existing = model.images;
    final picked = model.photos;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.productPhotos, style: AppText.title),
                      SizedBox(height: AppSpacing.xxs),
                      Text(l10n.productPhotosHint, style: AppText.labelMicro),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                AppIcon(AppIcons.box, size: 4.1.w, color: AppColors.textMuted),
              ],
            ),
          ),
          if (existing.isNotEmpty || picked.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final image in existing)
                  _Thumb(
                    removeLabel: l10n.productPhotoRemove,
                    // A legacy `imageUrl` has no row to delete, so it has no ✕.
                    onRemove: image.isDeletable ? () => model.removeImage(image) : null,
                    child: CachedNetworkImage(
                      imageUrl: image.url,
                      fit: BoxFit.cover,
                      memCacheWidth: 168,
                      errorWidget: (_, _, _) => const ColoredBox(color: AppColors.ink),
                      placeholder: (_, _) => const ColoredBox(color: AppColors.ink),
                    ),
                  ),
                for (var i = 0; i < picked.length; i++)
                  _Thumb(
                    removeLabel: l10n.productPhotoRemove,
                    onRemove: () => model.removePhoto(i),
                    child: Image.memory(
                      picked[i].bytes,
                      fit: BoxFit.cover,
                      // Decoded at thumbnail size: a 5 MB photo decoded in
                      // full is a lot of memory on this market's handsets.
                      cacheWidth: 168,
                      errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.ink),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.child,
    required this.removeLabel,
    required this.onRemove,
  });

  final Widget child;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 14.36.w, // 56
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: child,
            ),
          ),
          if (onRemove != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Semantics(
                button: true,
                label: removeLabel,
                child: GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(1.03.w),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: AppIcon(
                      AppIcons.close,
                      size: 3.08.w,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The web's `VariantEditor` in edit mode: the title with the total, *Add
/// Variant*, then a card per row.
class _VariantEditor extends StatelessWidget {
  const _VariantEditor({required this.model});

  final EditProductViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final rows = model.variants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: l10n.productVariantsTitle, style: AppText.title),
                    if (rows.isNotEmpty)
                      TextSpan(
                        text: '  ${l10n.productVariantsTotal(model.variantTotalQuantity)}',
                        style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),
            Semantics(
              button: true,
              child: GestureDetector(
                onTap: model.isBusy
                    ? null
                    : () {
                        final row = model.addVariant();
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => row.name.focusNode.requestFocus(),
                        );
                      },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(AppIcons.plus, size: 3.59.w, color: AppColors.accentMoney),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.productVariantAdd,
                        style: AppText.actionS.copyWith(color: AppColors.accentMoney),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        if (rows.isEmpty)
          Text(
            l10n.productVariantsEmpty,
            style: AppText.bodyS.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              height: 1.32,
            ),
          )
        else
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.sm),
            _VariantCard(model: model, row: rows[i]),
          ],
        if (model.showMissingVariants) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            l10n.productVariantsRequired,
            style: AppText.actionS.copyWith(color: AppColors.accentAlert),
          ),
        ],
      ],
    );
  }
}

/// One variant: name and SKU with the delete button, then cost and price, then
/// quantity and min quantity — the quantity locked on a saved row.
class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.model, required this.row});

  final EditProductViewModel model;
  final EditVariantRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    String? errorFor(FormFieldModel field) {
      final error = model.variantFieldError(field);
      return error == null ? null : tutorialFieldMessage(error, l10n);
    }

    final nameError = errorFor(row.name) ??
        (model.showDuplicate(row) ? l10n.productVariantDuplicate : null);
    const numberKeyboard = TextInputType.number;
    const amountKeyboard = TextInputType.numberWithOptions(decimal: true);
    final digits = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(9),
    ];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantName,
                  isRequired: true,
                  controller: row.name.controller,
                  focusNode: row.name.focusNode,
                  errorText: nameError,
                  placeholder: l10n.productVariantNamePlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                  onSubmitted: (_) => row.sku.focusNode.requestFocus(),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantSku,
                  controller: row.sku.controller,
                  focusNode: row.sku.focusNode,
                  placeholder: l10n.productVariantSkuPlaceholder,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                  onSubmitted: (_) => row.costPrice.focusNode.requestFocus(),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Padding(
                // Level with the inputs, under their labels.
                padding: EdgeInsets.only(top: 4.62.w), // 18
                child: Semantics(
                  button: true,
                  label: l10n.productVariantRemove,
                  child: GestureDetector(
                    onTap: model.isBusy ? null : () => model.removeVariant(row),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 9.23.w, // 36
                      height: AppSize.control,
                      child: Center(
                        child: AppIcon(
                          AppIcons.trash,
                          size: 4.1.w,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantCost,
                  controller: row.costPrice.controller,
                  focusNode: row.costPrice.focusNode,
                  errorText: errorFor(row.costPrice),
                  placeholder: '0',
                  keyboardType: amountKeyboard,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_amountFormatter],
                  onSubmitted: (_) => row.sellingPrice.focusNode.requestFocus(),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantPrice,
                  controller: row.sellingPrice.controller,
                  focusNode: row.sellingPrice.focusNode,
                  errorText: errorFor(row.sellingPrice),
                  placeholder: '0',
                  keyboardType: amountKeyboard,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [_amountFormatter],
                  onSubmitted: (_) => (row.isSaved ? row.minQuantity : row.quantity)
                      .focusNode
                      .requestFocus(),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantQuantity,
                  controller: row.quantity.controller,
                  focusNode: row.quantity.focusNode,
                  errorText: row.isSaved ? null : errorFor(row.quantity),
                  placeholder: '0',
                  keyboardType: numberKeyboard,
                  textInputAction: TextInputAction.next,
                  inputFormatters: digits,
                  // A saved variant's stock has no route on this form: PUT
                  // refuses a quantity, so the field is shown and locked.
                  enabled: !row.isSaved,
                  onSubmitted: (_) => row.minQuantity.focusNode.requestFocus(),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantMinQuantity,
                  controller: row.minQuantity.controller,
                  focusNode: row.minQuantity.focusNode,
                  errorText: errorFor(row.minQuantity),
                  placeholder: '0',
                  keyboardType: numberKeyboard,
                  textInputAction: TextInputAction.done,
                  inputFormatters: digits,
                  onSubmitted: (_) => row.minQuantity.focusNode.unfocus(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Digits, one decimal separator, and nothing else. A comma is allowed through
/// and normalised on parse — it is the French separator and what an Algerian
/// handset's keyboard offers.
final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/repositories/catalogue_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/add_product_view_model.dart';
import '../../viewmodels/form_draft_store.dart';
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

/// `18 — Ajouter un produit`.
///
/// The nine editable fields the web's Add Product modal has, in its order, plus
/// the variants section. Three things differ from the web, and one from the
/// frames:
///
/// - **The title says only "Add Product".** The web's modal heading doubles as
///   a mode switch (`Add Product` / `Edit Product`); on mobile the two are
///   separate screens, so each says one thing. See `EditProductScreen`, which
///   is this form minus the quantity and plus the unit's **+**.
/// - **Category and Unit are pickers, not dropdowns** — see [AppSelectField],
///   which also explains why the design system had no component for this.
/// - **Cost, price and margin are not previewed.** The web computes a live
///   margin under the two price fields; margin work stays on the web
///   (brief §14.3).
/// - **The photo row does not upload yet.** See [_Photos].
///
/// **Variants are the web's.** Ticking *This product has variants* hides the
/// product's initial quantity and opens the web's `VariantEditor` under the
/// box: "Variants" with the total quantity, *Add Variant*, and one card per
/// variant — name, SKU, cost, price, quantity, min quantity, and a delete
/// button. The web's four number columns are two rows of two here.
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late final AddProductViewModel _model = AddProductViewModel(
    products: context.read<ProductRepository>(),
    catalogue: context.read<CatalogueRepository>(),
    // Looked up optionally, so the screen still builds without the store.
    drafts: context.read<FormDraftStore?>(),
  );

  @override
  void initState() {
    super.initState();
    // The selling price's validity depends on the cost price, so the form has
    // to re-evaluate when the cost changes, not only when selling does.
    _model.costPrice.controller.addListener(_model.onCostPriceChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.loadOptions());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _picking = false;

  /// One photo from the camera, or several from the gallery.
  Future<void> _pickPhotos() async {
    if (_picking) return;
    _picking = true;
    try {
      final picked = await pickProductPhotos(
        context,
        limit: AddProductViewModel.maxPhotos - _model.photos.length,
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
  /// Busy: ignored, so a create in flight is never orphaned. Created (the
  /// photos failed and the screen stayed): closes as a success, so the list
  /// reloads. Dirty: the leave sheet first. Clean: the intercept is inactive
  /// and the navigator pops by itself.
  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (_model.created != null) {
      _closeCreated();
      return false;
    }
    return showLeaveSheet(context, body: L10n.of(context).productFormLeaveBody);
  }

  /// `true` is what tells `17` to refetch its rows and its two figures. An
  /// explicit pop, so it bypasses the back intercept.
  void _closeCreated() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(Routes.products);
    }
  }

  Future<void> _create() async {
    final product = await _model.submitAndCreate();
    if (product == null || !mounted) return;

    // Raised on the root messenger before the pop, and read on the list
    // underneath it. A failure is *not* toasted — it stays in the line above
    // the button, where the merchant can see it while they fix the field.
    // The product exists either way; a failed photo upload is said, not hidden.
    if (_model.photosFailed) {
      AppToast.info(context, L10n.of(context).productPhotosUploadFailed);
    } else {
      AppToast.success(context, L10n.of(context).toastProductCreated);
    }

    _closeCreated();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    return ChangeNotifierProvider<AddProductViewModel>.value(
      value: _model,
      child: Consumer<AddProductViewModel>(
        builder: (context, model, _) {
          // Our own validators first, then the server's.
          //
          // Ours run on every keystroke and are what the merchant is
          // correcting right now; the server's arrive once, on submit, and
          // describe the state at that moment. Showing a stale server message
          // over a field the merchant has since fixed would be worse than
          // showing nothing.
          String? errorFor(FormFieldModel field, String apiName) {
            final local = model.visibleError(field);
            if (local != null) return tutorialFieldMessage(local, l10n);
            return model.serverFieldErrors[apiName];
          }

          // Clean and idle: inactive, so back pops natively (or goes to the
          // list, the route's parent). See [_onBack] for the rest.
          return BackIntercept(
            active: model.hasChanges || model.isBusy || model.created != null,
            onBack: _onBack,
            child: Scaffold(
            backgroundColor: AppColors.ink,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: gutter.copyWith(
                      top: 0.47.h, // 4
                      bottom: AppSpacing.lg, // 16
                    ),
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
                          Text(l10n.productAddTitle, style: AppText.displayM),
                          SizedBox(height: AppSpacing.xl), // 20
                          _Fields(
                            model: model,
                            errorFor: errorFor,
                            onAddPhotos: _pickPhotos,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: gutter.copyWith(
                      top: AppSpacing.md, // 12
                      bottom: 3.32.h, // 28
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The summary line. A 400 that named specific inputs
                        // has already put its messages on those fields above;
                        // this carries the rules the server states without
                        // blaming a field — a duplicate SKU among them.
                        ApiErrorLine(error: model.submitError),
                        // The product exists and a variant did not make it: the
                        // next tap sends only the variants still missing.
                        if (model.created != null && model.submitError != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Text(
                              l10n.productVariantsRetryHint,
                              textAlign: TextAlign.center,
                              style: AppText.actionS.copyWith(color: AppColors.textMuted),
                            ),
                          ),
                        FilledButton(
                          // Disabled while in flight. This matters more than a
                          // spinner: a double tap would otherwise send two
                          // products, and the second fails on the unique SKU
                          // for a product the merchant just created.
                          onPressed: model.isBusy ? null : _create,
                          child: model.isBusy
                              ? SizedBox.square(
                                  dimension: AppSpacing.gutterTight,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.ink,
                                  ),
                                )
                              : Text(l10n.productAddSubmit),
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
}

class _Fields extends StatelessWidget {
  const _Fields({
    required this.model,
    required this.errorFor,
    required this.onAddPhotos,
  });

  final AddProductViewModel model;

  /// Opens the phone's file browser — owned by the screen, which holds the
  /// splash replay while it is open.
  final VoidCallback onAddPhotos;
  final String? Function(FormFieldModel field, String apiName) errorFor;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

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
          // The column is varchar(255), and exceeding it is a **500** on this
          // route rather than a 400 — so it is capped at the keyboard and
          // never sent long.
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
        AppTextField(
          label: l10n.productCostPrice,
          isRequired: true,
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
          isRequired: true,
          controller: model.sellingPrice.controller,
          focusNode: model.sellingPrice.focusNode,
          errorText: errorFor(model.sellingPrice, 'sellingPrice'),
          placeholder: '0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [_amountFormatter],
          // The quantity is not on the form while variants are on.
          onSubmitted: (_) =>
              (model.hasVariants ? model.minQuantity : model.quantity).focusNode.requestFocus(),
        ),
        _gap,
        // The web hides the product-level quantity when variants are on: the
        // variants carry the stock, and the backend sums it.
        if (!model.hasVariants) ...[
          AppTextField(
            label: l10n.productQuantity,
            isRequired: true,
            controller: model.quantity.controller,
            focusNode: model.quantity.focusNode,
            errorText: errorFor(model.quantity, 'quantity'),
            placeholder: '0',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            onSubmitted: (_) => model.minQuantity.focusNode.requestFocus(),
          ),
          _gap,
        ],
        AppTextField(
          label: l10n.productAlertThreshold,
          controller: model.minQuantity.controller,
          focusNode: model.minQuantity.focusNode,
          errorText: errorFor(model.minQuantity, 'minQuantity'),
          placeholder: '0',
          hint: l10n.productAlertThresholdHint,
          keyboardType: TextInputType.number,
          // The last *keyboard* field on the form: the two below it are
          // pickers, so there is nothing to advance to and the action closes
          // the keyboard instead of promising a next field that does not
          // exist.
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
          // A new account has no categories — they are created on the web —
          // so the field stays inert rather than opening a sheet with one
          // option in it that does nothing.
          enabled: model.categories.isNotEmpty,
          options: [
            // "None" first, and always present: this field is optional, and
            // without it a merchant who picked a category by mistake could
            // never take it off again.
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
        AppSelectField<String>(
          label: l10n.productUnit,
          placeholder: l10n.productUnitNone,
          value: model.unitId,
          onChanged: model.setUnit,
          enabled: model.units.isNotEmpty,
          options: [
            SelectOption<String>(value: null, label: l10n.productUnitNone),
            for (final unit in model.units)
              SelectOption<String>(value: unit.id, label: unit.label),
          ],
        ),
        _gap,
        _Photos(
          photos: model.photos,
          onAdd: model.isBusy ? null : onAddPhotos,
          onRemove: model.removePhoto,
        ),
        SizedBox(height: AppSpacing.lg), // 16
        AppCheckbox(
          label: l10n.productHasVariants,
          hint: l10n.productHasVariantsHint,
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

  /// 14 between fields, from the frame — tighter than the 16 the auth screens
  /// use, because this form is nine controls deep rather than four.
  Widget get _gap => SizedBox(height: 3.59.w); // 14
}

/// The web's `VariantEditor`: the title with the total quantity, *Add
/// Variant*, then a card per variant — or the web's empty line.
class _VariantEditor extends StatelessWidget {
  const _VariantEditor({required this.model});

  final AddProductViewModel model;

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
                        // Straight into the new row's name, once it is built.
                        WidgetsBinding.instance.addPostFrameCallback((_) => row.name.focusNode.requestFocus());
                      },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcon(AppIcons.plus, size: 3.59.w, color: AppColors.accentMoney), // 14
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
/// quantity and min quantity.
class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.model, required this.row});

  final AddProductViewModel model;
  final VariantRowModel row;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    String? errorFor(FormFieldModel field) {
      final error = model.variantFieldError(field);
      return error == null ? null : tutorialFieldMessage(error, l10n);
    }

    final nameError = errorFor(row.name) ?? (model.showDuplicate(row) ? l10n.productVariantDuplicate : null);
    const numberKeyboard = TextInputType.number;
    const amountKeyboard = TextInputType.numberWithOptions(decimal: true);
    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)];

    return Container(
      padding: EdgeInsets.all(AppSpacing.md), // 12
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
              // Not on a variant the backend already created: it exists.
              if (row.createdId == null) ...[
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
                          child: AppIcon(AppIcons.trash, size: 4.1.w, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                  onSubmitted: (_) => row.quantity.focusNode.requestFocus(),
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
                  errorText: errorFor(row.quantity),
                  placeholder: '0',
                  keyboardType: numberKeyboard,
                  textInputAction: TextInputAction.next,
                  inputFormatters: digits,
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

/// The photo row: tap to add from the camera or the gallery, then a thumbnail
/// per picked photo with a remove control.
///
/// Photos are uploaded right after the product is created — the backend
/// attaches images to a product id (`POST …/products/{id}/images`), so they
/// cannot travel with the create call.
class _Photos extends StatelessWidget {
  const _Photos({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ProductPhoto> photos;

  /// Null while the form is sending.
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md), // 12
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
                      SizedBox(height: AppSpacing.xxs), // 2
                      Text(l10n.productPhotosHint, style: AppText.labelMicro),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                AppIcon(
                  AppIcons.box,
                  size: 4.1.w, // 16
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          if (photos.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md), // 12
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var i = 0; i < photos.length; i++)
                  _Thumb(
                    photo: photos[i],
                    removeLabel: l10n.productPhotoRemove,
                    onRemove: () => onRemove(i),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One picked photo, with a remove control on its end corner.
class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.photo,
    required this.removeLabel,
    required this.onRemove,
  });

  final ProductPhoto photo;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 14.36.w, // 56
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.memory(
                photo.bytes,
                fit: BoxFit.cover,
                // Decoded at thumbnail size: a 5 MB photo decoded in full is
                // a lot of memory on this market's handsets.
                cacheWidth: 168,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppColors.ink),
              ),
            ),
          ),
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
                  padding: EdgeInsets.all(1.03.w), // 4
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    border: Border.all(
                      color: AppColors.rule,
                      width: AppStroke.hairline,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: AppIcon(
                    AppIcons.close,
                    size: 3.08.w, // 12
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

/// Digits, one decimal separator, and nothing else.
///
/// A comma is allowed through and normalised on parse: it is the French
/// decimal separator and what an Algerian handset's keyboard offers, and
/// rejecting it at the keyboard would make the field feel broken.
final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

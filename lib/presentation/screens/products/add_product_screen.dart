import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/catalogue_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/add_product_view_model.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../viewmodels/form_field_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/icon_square_button.dart';
import '../tutorial/tutorial_messages.dart';

/// `18 — Ajouter un produit`.
///
/// The nine editable fields the web's Add Product modal has, in its order, plus
/// the variants checkbox. Three things differ from the web, and one from the
/// frames:
///
/// - **The title says only "Add Product".** The web's modal heading doubles as
///   a mode switch (`Add Product` / `Edit Product`); there is no edit screen on
///   mobile yet, so there is nothing to distinguish it from.
/// - **Category and Unit are pickers, not dropdowns** — see [AppSelectField],
///   which also explains why the design system had no component for this.
/// - **Cost, price and margin are not previewed.** The web computes a live
///   margin under the two price fields; margin work stays on the web
///   (brief §14.3).
/// - **The photo row does not upload yet.** See [_Photos].
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
    final source = await _chooseSource();
    if (source == null || !mounted) return;

    _picking = true;
    // The camera and the gallery send the app to the background, and a splash
    // replay on the way back would rebuild this screen and lose the pick.
    final session = context.read<SessionViewModel?>();
    session?.holdSplashReplay();
    var files = const <XFile>[];
    try {
      final picker = ImagePicker();
      // Re-encoded at a sensible size: a phone camera's own photo can pass
      // the backend's 5 MB limit by itself.
      if (source == ImageSource.camera) {
        final shot = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 2000,
          maxHeight: 2000,
          imageQuality: 85,
        );
        files = [?shot];
      } else {
        files = await picker.pickMultiImage(
          maxWidth: 2000,
          maxHeight: 2000,
          imageQuality: 85,
          limit: AddProductViewModel.maxPhotos,
        );
      }
    } on Exception catch (error) {
      Log.w('photo picker failed: $error', tag: 'products');
    } finally {
      session?.releaseSplashReplay();
      _picking = false;
    }
    if (files.isEmpty || !mounted) return;

    final picked = <ProductPhoto>[];
    for (final file in files) {
      try {
        picked.add(
          ProductPhoto(name: file.name, bytes: await file.readAsBytes()),
        );
      } on Exception catch (error) {
        Log.w('could not read ${file.name}: $error', tag: 'products');
      }
    }
    if (!mounted) return;

    final rejected = _model.addPhotos(picked);
    final l10n = L10n.of(context);
    if (rejected.contains(PhotoRejection.tooMany)) {
      AppToast.info(context, l10n.productPhotosTooMany);
    } else if (rejected.contains(PhotoRejection.tooLarge)) {
      AppToast.info(context, l10n.productPhotosTooLarge);
    } else if (rejected.contains(PhotoRejection.wrongType)) {
      AppToast.info(context, l10n.productPhotosWrongType);
    }
  }

  /// Camera or gallery, asked in a sheet.
  Future<ImageSource?> _chooseSource() {
    final l10n = L10n.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (source, label) in [
              (ImageSource.camera, l10n.productPhotoCamera),
              (ImageSource.gallery, l10n.productPhotoGallery),
            ])
              ListTile(
                title: Text(
                  label,
                  style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                ),
                onTap: () => Navigator.of(sheet).pop(source),
              ),
          ],
        ),
      ),
    );
  }

  void _back() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(false);
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

    final router = GoRouter.of(context);
    // `true` is what tells `17` to refetch its rows and its two figures.
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(Routes.products);
    }
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

          return Scaffold(
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
                      child: AppBackButton(
                        onBack: _back,
                        semanticLabel: l10n.commonBack,
                      ),
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
          onSubmitted: (_) => model.quantity.focusNode.requestFocus(),
        ),
        _gap,
        AppTextField(
          label: l10n.productQuantity,
          // Stops being required the moment the variants box is ticked, which
          // is the server's own rule — the variants carry the stock.
          isRequired: !model.hasVariants,
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
      ],
    );
  }

  /// 14 between fields, from the frame — tighter than the 16 the auth screens
  /// use, because this form is nine controls deep rather than four.
  Widget get _gap => SizedBox(height: 3.59.w); // 14
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

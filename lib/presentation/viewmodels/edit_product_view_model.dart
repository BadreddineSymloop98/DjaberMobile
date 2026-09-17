import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/catalogue.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalogue_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'add_product_view_model.dart' show PhotoRejection;
import 'base_view_model.dart';
import 'form_field_model.dart';

/// One row of the variant editor **in edit mode**.
///
/// Deliberately not [VariantRowModel] from the create form, because the two
/// differ in the one place that matters: a row here may already exist on the
/// server, and that changes what the row is allowed to do.
///
/// - [serverId] null — a row the merchant just added. Every field is editable,
///   including the quantity, and it is written with `POST …/variants`, which
///   takes an opening stock.
/// - [serverId] set — a saved variant. `PUT …/variants/{id}` **cannot carry a
///   quantity** (live docs), so the quantity field is locked and shown at 40%,
///   exactly as the web disables it (`disabled={isEditing && !!v.id}`) and as
///   the Figma frame draws it. Stock moves through *Ajuster le stock*.
class EditVariantRow {
  EditVariantRow({
    this.serverId,
    String name = '',
    String sku = '',
    String costPrice = '0',
    String sellingPrice = '0',
    String quantity = '0',
    String minQuantity = '0',
  })  : name = FormFieldModel(validator: Validators.name, initialValue: name),
        sku = FormFieldModel(validator: Validators.optional, initialValue: sku),
        costPrice = FormFieldModel(
          validator: Validators.optionalAmount,
          initialValue: costPrice,
        ),
        sellingPrice = FormFieldModel(
          validator: Validators.optionalAmount,
          initialValue: sellingPrice,
        ),
        quantity = FormFieldModel(
          validator: Validators.threshold,
          initialValue: quantity,
        ),
        minQuantity = FormFieldModel(
          validator: Validators.threshold,
          initialValue: minQuantity,
        );

  /// A saved variant, filled from the detail response.
  factory EditVariantRow.of(ProductVariant variant) => EditVariantRow(
        serverId: variant.id,
        name: variant.name,
        sku: variant.sku ?? '',
        costPrice: _amountText(variant.costPrice),
        sellingPrice: _amountText(variant.sellingPrice),
        quantity: '${variant.quantity}',
        minQuantity: '${variant.minQuantity}',
      );

  /// Null until the backend has the row. Set the moment a new row is created,
  /// so a retry after a partial failure updates it instead of adding a second
  /// variant with the same name — which the backend would refuse anyway.
  String? serverId;

  final FormFieldModel name;
  final FormFieldModel sku;
  final FormFieldModel costPrice;
  final FormFieldModel sellingPrice;
  final FormFieldModel quantity;
  final FormFieldModel minQuantity;

  /// True once the row exists on the server — which is also what locks the
  /// quantity field.
  bool get isSaved => serverId != null;

  List<FormFieldModel> get fields =>
      [name, sku, costPrice, sellingPrice, quantity, minQuantity];

  bool get isValid => fields.every((field) => field.isValid);

  /// What the row looked like when it was loaded, so the form can tell an
  /// untouched product from an edited one without diffing against the model.
  String _snapshot = '';
  void takeSnapshot() => _snapshot = _signature;
  bool get isDirty => _signature != _snapshot;

  String get _signature => [
        name.value.trim(),
        sku.value.trim(),
        costPrice.value.trim(),
        sellingPrice.value.trim(),
        quantity.value.trim(),
        minQuantity.value.trim(),
      ].join('|');

  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
  }
}

/// `Edit product` — the web's Add/Edit modal in its edit mode, on
/// `/dashboard/stock/products`.
///
/// **What edit is allowed to change, and what it is not.** The live docs draw
/// the line, not taste: `PUT /products/{id}` updates prices, metadata and
/// activation and says outright that `quantity` and `hasVariants` "CANNOT be
/// changed here". So the form has no quantity field at all — the frame does not
/// draw one — and a saved variant's quantity is locked. Stock is the *Ajuster
/// le stock* screen's job, which is what the hint under the checkbox says.
///
/// **Validation is looser than on create, as on the web.** `validateForm` there
/// only requires the name and the SKU when `editing` is set; the prices and the
/// quantity are required on create alone. The server agrees — update checks
/// only that a number is non-negative. The one rule kept from create is
/// selling ≥ cost, which the web applies in both modes.
///
/// **Saving follows the web's order**, so a merchant who edits on both gets the
/// same result: update the product, then per variant row update it when it has
/// an id and create it when it does not, then delete the rows that were taken
/// off. Unticking the box deletes every variant the product had.
///
/// **Every step is resumable.** A failure part-way leaves the work already done
/// recorded — created rows keep their id, deleted ids are remembered, uploaded
/// photos are marked — so pressing the button again finishes the job instead of
/// creating duplicates or deleting twice. The create form does the same for its
/// variants; here there is more to lose, because deletes move stock.
class EditProductViewModel extends FormViewModel {
  EditProductViewModel({
    required ProductRepository products,
    required CatalogueRepository catalogue,
    required this.productId,
  })  : _products = products,
        _catalogue = catalogue {
    attachFields();
  }

  final ProductRepository _products;
  final CatalogueRepository _catalogue;
  final String productId;

  final name = FormFieldModel(validator: Validators.name);
  final sku = FormFieldModel(validator: Validators.name);
  final description = FormFieldModel(validator: Validators.optional);

  /// Optional on update — the server only asks for non-negative, and the web's
  /// own validator skips the required check when editing.
  final costPrice = FormFieldModel(validator: Validators.optionalAmount);

  /// Optional too, but still compared against the cost price: the web keeps
  /// that rule in both modes, and a selling price under cost is a typo either
  /// way. Quiet while the cost field is empty or unreadable — there is nothing
  /// to compare against.
  late final sellingPrice = FormFieldModel(
    validator: (value) {
      final own = Validators.optionalAmount(value);
      if (own != null) return own;
      final cost = Validators.parseAmount(costPrice.value);
      final asked = Validators.parseAmount(value);
      if (cost == null || asked == null) return null;
      return asked < cost ? FieldError.belowCostPrice : null;
    },
  );

  final minQuantity = FormFieldModel(validator: Validators.threshold);

  @override
  List<FormFieldModel> get fields =>
      [name, sku, description, costPrice, sellingPrice, minQuantity];

  // ---- Loading ----

  Product? _product;

  /// The product as the server last described it. Null until [load] succeeds.
  Product? get product => _product;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  List<ProductCategory> _categories = const [];
  List<ProductUnit> _units = const [];
  List<ProductCategory> get categories => _categories;
  List<ProductUnit> get units => _units;

  String? _categoryId;
  String? _unitId;
  String? get categoryId => _categoryId;
  String? get unitId => _unitId;

  bool _hasVariants = false;
  bool get hasVariants => _hasVariants;

  /// Reads the product and the two lookup lists together.
  ///
  /// The product is the only one that must succeed — without it there is
  /// nothing to edit, and the screen shows the error with a retry. A lookup
  /// that fails leaves its picker empty, exactly as it does on the create
  /// form: both fields are optional.
  ///
  /// `GET /products/{id}` is the right read here rather than whatever the list
  /// handed over, because it is the only one that returns **every** variant,
  /// inactive ones included, and every image with its row id.
  Future<void> load() async {
    // Cleared first so a retry shows the spinner again instead of sitting on
    // the message it is retrying.
    clearError();
    final results = await Future.wait([
      _products.get(productId),
      _catalogue.categories(),
      _catalogue.units(),
    ]);
    if (isDisposed) return;

    if (results[1] case Success(:final value)) {
      _categories = value as List<ProductCategory>;
    }
    if (results[2] case Success(:final value)) {
      _units = value as List<ProductUnit>;
    }

    switch (results[0]) {
      case Success(:final value):
        _fill(value as Product);
        _loaded = true;
        setState(ViewState.ready);
      case Failure(:final error):
        setError(error);
    }
    safeNotify();
  }

  void _fill(Product product) {
    _product = product;
    name.controller.text = product.name;
    sku.controller.text = product.sku;
    description.controller.text = product.description ?? '';
    costPrice.controller.text = _amountText(product.costPrice);
    sellingPrice.controller.text = _amountText(product.sellingPrice);
    minQuantity.controller.text = '${product.minQuantity}';
    _categoryId = product.categoryId;
    _unitId = product.unitId;
    _hasVariants = product.hasVariants;

    for (final row in _variants) {
      row.dispose();
    }
    _variants
      ..clear()
      ..addAll([
        for (final variant in product.variants) EditVariantRow.of(variant)..takeSnapshot(),
      ]);
    for (final row in _variants) {
      _listenTo(row);
    }

    _images = [...product.images];
    _removedImageIds.clear();
    _deletedVariantIds.clear();
    _photos.clear();
    _snapshot = _signature;
  }

  // ---- Pickers ----

  void setCategory(String? id) {
    if (_categoryId == id) return;
    _categoryId = id;
    safeNotify();
  }

  void setUnit(String? id) {
    if (_unitId == id) return;
    _unitId = id;
    safeNotify();
  }

  /// The web's *Add Custom Unit*: create it, put it in the list, and select it.
  ///
  /// Returns null on success, the failure otherwise — the sheet keeps what was
  /// typed and shows the message, so a duplicate name (a 400) can be corrected
  /// without retyping the abbreviation.
  Future<AppException?> createUnit({
    required String name,
    required String abbreviation,
  }) async {
    final result = await _catalogue.createUnit(
      name: name,
      abbreviation: abbreviation,
    );
    if (isDisposed) return null;
    switch (result) {
      case Success(:final value):
        _units = [..._units, value];
        _unitId = value.id;
        safeNotify();
        return null;
      case Failure(:final error):
        return error;
    }
  }

  // ---- Variants ----

  final List<EditVariantRow> _variants = [];
  List<EditVariantRow> get variants => List.unmodifiable(_variants);

  /// Ids the merchant took off the editor that the server still has. Sent as
  /// deletes on save, in the web's order: updates and creates first, removals
  /// last.
  final Set<String> _pendingVariantDeletes = {};

  /// Deletes already carried out, so a retry after a later failure does not
  /// send a second `DELETE` for a row that is gone (a 404).
  final Set<String> _deletedVariantIds = {};

  /// The web's "Total qty" — over the rows on screen, saved and new alike.
  int get variantTotalQuantity =>
      _variants.fold(0, (sum, row) => sum + (int.tryParse(row.quantity.value.trim()) ?? 0));

  EditVariantRow addVariant() {
    final row = EditVariantRow();
    _variants.add(row);
    _listenTo(row);
    safeNotify();
    return row;
  }

  /// Takes a row off the editor. A saved one is queued for deletion rather
  /// than deleted now — nothing is destroyed until the merchant saves, which
  /// is what makes backing out of the screen harmless.
  void removeVariant(EditVariantRow row) {
    if (!_variants.remove(row)) return;
    final id = row.serverId;
    if (id != null) _pendingVariantDeletes.add(id);
    safeNotify();
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  /// Saved variants that saving would destroy: the queued removals, plus every
  /// one of them when the box has been unticked.
  ///
  /// The screen asks before sending these. The backend's delete is hard and it
  /// moves stock — it writes an `adjustment` of `-quantity` reasoned "Variant
  /// deleted" and recomputes the product's total — so it is not something to
  /// discover after the fact. **The web does neither**: it deletes on save
  /// without a word.
  int get variantsToDelete {
    final product = _product;
    if (!_hasVariants && product != null && product.hasVariants) {
      return product.variants.where((v) => !_deletedVariantIds.contains(v.id)).length;
    }
    return _pendingVariantDeletes.difference(_deletedVariantIds).length;
  }

  /// Units of stock those deletions would write off, for the confirmation.
  int get stockToLose {
    final product = _product;
    if (product == null) return 0;
    final doomed = !_hasVariants && product.hasVariants
        ? product.variants.map((v) => v.id).toSet()
        : _pendingVariantDeletes;
    return product.variants
        .where((v) => doomed.contains(v.id) && !_deletedVariantIds.contains(v.id) && v.isActive)
        .fold(0, (sum, v) => sum + v.quantity);
  }

  void toggleHasVariants(bool value) {
    if (_hasVariants == value) return;
    _hasVariants = value;
    safeNotify();
  }

  bool _variantsAttempted = false;

  FieldError? variantFieldError(FormFieldModel field) {
    final error = field.error;
    if (error == null) return null;
    return (field.hasFocus || _variantsAttempted) ? error : null;
  }

  /// A row repeating an earlier row's name — the backend's per-product unique
  /// rule, which is a 400 and would otherwise land mid-save.
  bool isDuplicateName(EditVariantRow row) {
    final key = row.name.value.trim().toLowerCase();
    if (key.isEmpty) return false;
    for (final other in _variants) {
      if (identical(other, row)) return false;
      if (other.name.value.trim().toLowerCase() == key) return true;
    }
    return false;
  }

  bool showDuplicate(EditVariantRow row) =>
      isDuplicateName(row) && (row.name.hasFocus || _variantsAttempted);

  bool get showMissingVariants =>
      _variantsAttempted && _hasVariants && _variants.isEmpty;

  bool _checkVariants({required bool moveFocus}) {
    if (!_hasVariants) {
      _variantsAttempted = false;
      return true;
    }
    final ok = _variants.isNotEmpty &&
        _variants.every((row) => row.isValid && !isDuplicateName(row));
    _variantsAttempted = !ok;
    if (!ok && moveFocus) {
      for (final row in _variants) {
        if (!row.isValid) {
          row.fields.firstWhere((field) => !field.isValid).focusNode.requestFocus();
          break;
        }
        if (isDuplicateName(row)) {
          row.name.focusNode.requestFocus();
          break;
        }
      }
    }
    safeNotify();
    return ok;
  }

  void _listenTo(EditVariantRow row) {
    for (final field in row.fields) {
      field.controller.addListener(() {
        if (field.consumeTextChange()) safeNotify();
      });
      field.focusNode.addListener(safeNotify);
    }
  }

  // ---- Photos ----

  /// The backend's limits for one upload, as on the create form: 10 files,
  /// 5 MB each, accepted by extension, and a breach answered with a generic
  /// 500 rather than a 4xx.
  static const maxPhotos = 10;
  static const maxPhotoBytes = 5 * 1024 * 1024;
  static const photoExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  List<ProductImage> _images = const [];

  /// The photos the product already has, minus the ones removed on this
  /// screen. Removal is queued like a variant's: nothing is deleted until
  /// save, which the web does not do — it deletes the moment the ✕ is tapped.
  List<ProductImage> get images =>
      [for (final image in _images) if (!_removedImageIds.contains(image.id)) image];

  final Set<String> _removedImageIds = {};

  /// Deletions already carried out, so a retry does not repeat one.
  final Set<String> _deletedImageIds = {};

  final List<ProductPhoto> _photos = [];
  List<ProductPhoto> get photos => List.unmodifiable(_photos);

  /// How many more the product can take — existing kept images count towards
  /// the backend's ceiling.
  int get photoSlotsLeft => maxPhotos - images.length - _photos.length;

  Set<PhotoRejection> addPhotos(Iterable<ProductPhoto> picked) {
    final rejected = <PhotoRejection>{};
    for (final photo in picked) {
      if (!photoExtensions.contains(photo.extension)) {
        rejected.add(PhotoRejection.wrongType);
      } else if (photo.bytes.length > maxPhotoBytes) {
        rejected.add(PhotoRejection.tooLarge);
      } else if (photoSlotsLeft <= 0) {
        rejected.add(PhotoRejection.tooMany);
      } else {
        _photos.add(photo);
      }
    }
    safeNotify();
    return rejected;
  }

  void removePhoto(int index) {
    if (index < 0 || index >= _photos.length) return;
    _photos.removeAt(index);
    safeNotify();
  }

  /// Queues an existing image for deletion. One with no row id — the legacy
  /// `imageUrl` column — cannot be removed, and the screen does not offer it.
  void removeImage(ProductImage image) {
    if (!image.isDeletable) return;
    _removedImageIds.add(image.id);
    safeNotify();
  }

  bool _photosUploaded = false;
  bool _photosFailed = false;

  /// True when everything else saved but the new photos could not be sent.
  bool get photosFailed => _photosFailed;

  // ---- Change tracking ----

  String _snapshot = '';

  String get _signature => [
        name.value.trim(),
        sku.value.trim(),
        description.value.trim(),
        costPrice.value.trim(),
        sellingPrice.value.trim(),
        minQuantity.value.trim(),
        _categoryId ?? '',
        _unitId ?? '',
        '$_hasVariants',
      ].join('|');

  /// The form holds something back would throw away.
  ///
  /// Compared against what was loaded rather than against "is anything typed",
  /// which is the create form's test: here every field starts full, so that
  /// question is always yes.
  bool get hasChanges =>
      _loaded &&
      !_saved &&
      (_signature != _snapshot ||
          _photos.isNotEmpty ||
          _removedImageIds.isNotEmpty ||
          _pendingVariantDeletes.isNotEmpty ||
          _variants.any((row) => !row.isSaved || row.isDirty));

  bool _saved = false;

  /// True once the save went all the way through.
  bool get isSaved => _saved;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// The server's message per input it faulted, keyed as the request sent it.
  Map<String, String> get serverFieldErrors =>
      _submitError?.fieldMessages ?? const {};

  /// Validates, then saves. Returns the updated product, or null.
  ///
  /// Nothing here navigates or asks anything — the screen confirms the
  /// destructive part before calling this.
  /// Runs every check the save would run — the fields, then the variant rows —
  /// and reveals the errors, moving focus to the first one.
  ///
  /// Public so the screen can call it **before** asking the merchant to confirm
  /// deleting variants: that question must only be asked about a save that is
  /// actually going to happen.
  bool validateForSave() {
    final fieldsOk = submit();
    final variantsOk = _checkVariants(moveFocus: fieldsOk);
    return fieldsOk && variantsOk;
  }

  Future<Product?> submitAndSave() async {
    _submitError = null;
    if (!validateForSave()) return null;

    final original = _product;
    if (original == null) return null;

    return run(
      () async {
        // 1. The product itself. A plain PUT, so repeating it after a later
        //    failure is harmless — which is why it is not guarded by a flag.
        final updated = await _products.update(
          productId,
          sku: sku.value,
          name: name.value,
          description: description.value,
          costPrice: Validators.parseAmount(costPrice.value),
          sellingPrice: Validators.parseAmount(sellingPrice.value),
          minQuantity: int.tryParse(minQuantity.value.trim().replaceAll(' ', '')) ?? 0,
          categoryId: _categoryId,
          unitId: _unitId,
        );
        final product = updated.valueOrNull;
        if (product == null) return updated;

        // 2. The variant rows, in the web's order: existing ones updated,
        //    new ones created.
        if (_hasVariants) {
          for (final row in _variants) {
            final id = row.serverId;
            if (id != null) {
              // Only when something on the row actually changed: an untouched
              // variant needs no write, and skipping it keeps a long editor
              // from firing a dozen identical requests.
              if (!row.isDirty) continue;
              final result = await _products.updateVariant(
                productId: productId,
                variantId: id,
                name: row.name.value,
                sku: row.sku.value,
                costPrice: Validators.parseAmount(row.costPrice.value) ?? 0,
                sellingPrice: Validators.parseAmount(row.sellingPrice.value) ?? 0,
                minQuantity: _asInt(row.minQuantity.value),
              );
              if (result.errorOrNull case final error?) {
                return Result<Product>.failure(error);
              }
              row.takeSnapshot();
            } else {
              final result = await _products.createVariant(
                productId: productId,
                name: row.name.value,
                sku: row.sku.value,
                costPrice: Validators.parseAmount(row.costPrice.value) ?? 0,
                sellingPrice: Validators.parseAmount(row.sellingPrice.value) ?? 0,
                quantity: _asInt(row.quantity.value),
                minQuantity: _asInt(row.minQuantity.value),
              );
              final variant = result.valueOrNull;
              if (variant == null) {
                return Result<Product>.failure(result.errorOrNull!);
              }
              // Recorded immediately: a failure on the next row must not make
              // a second attempt create this one twice.
              row.serverId = variant.id;
              row.takeSnapshot();
            }
          }
        }

        // 3. The removals. Queued ones when the box is still ticked; every
        //    variant the product had when it has been unticked — the web's
        //    `else if (editing.hasVariants)` branch.
        final doomed = _hasVariants
            ? _pendingVariantDeletes.toList()
            : [for (final variant in original.variants) variant.id];
        for (final id in doomed) {
          if (_deletedVariantIds.contains(id)) continue;
          final result = await _products.deleteVariant(
            productId: productId,
            variantId: id,
          );
          if (result.errorOrNull case final error?) {
            return Result<Product>.failure(error);
          }
          _deletedVariantIds.add(id);
        }

        // 4. Images removed on this screen.
        for (final id in _removedImageIds) {
          if (_deletedImageIds.contains(id)) continue;
          final result = await _products.deleteImage(
            productId: productId,
            imageId: id,
          );
          if (result.errorOrNull case final error?) {
            return Result<Product>.failure(error);
          }
          _deletedImageIds.add(id);
        }

        // 5. New photos, last — as the web does, and because a failed upload
        //    must not hold back the edit itself. It is reported, not hidden.
        if (_photos.isNotEmpty && !_photosUploaded) {
          final upload = await _products.uploadImages(
            productId: productId,
            photos: _photos,
          );
          _photosUploaded = upload.isSuccess;
          _photosFailed = upload.isFailure;
        }

        _saved = true;
        return Result<Product>.success(product);
      },
      onError: (error) => _submitError = error,
      tag: 'updateProduct',
    );
  }

  static int _asInt(String value) =>
      int.tryParse(value.trim().replaceAll(' ', '')) ?? 0;

  @override
  void dispose() {
    for (final row in _variants) {
      row.dispose();
    }
    super.dispose();
  }
}

/// A price as the form should show it: `1800` rather than `1800.0`, `1250.5`
/// kept as typed.
///
/// The backend sends Decimal(10,2) as a string and [Product] parses it to a
/// double, so a whole-number price arrives as `1800.0` — which would put a
/// stray `.0` in the field the merchant is about to edit.
String _amountText(double value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';

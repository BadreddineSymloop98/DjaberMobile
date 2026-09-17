import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/catalogue.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalogue_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';

/// Why a picked photo was not added to the form.
enum PhotoRejection { wrongType, tooLarge, tooMany }

/// One row of the web's `VariantEditor` (`src/components/stock/VariantEditor.tsx`):
/// name, SKU, cost, price, quantity, min quantity — every number starting at
/// `0`, as the web's `addRow` does.
class VariantRowModel {
  VariantRowModel({
    String name = '',
    String sku = '',
    String costPrice = '0',
    String sellingPrice = '0',
    String quantity = '0',
    String minQuantity = '0',
  })  : name = FormFieldModel(validator: Validators.name, initialValue: name),
        sku = FormFieldModel(validator: Validators.optional, initialValue: sku),
        costPrice = FormFieldModel(validator: Validators.optionalAmount, initialValue: costPrice),
        sellingPrice = FormFieldModel(validator: Validators.optionalAmount, initialValue: sellingPrice),
        quantity = FormFieldModel(validator: Validators.threshold, initialValue: quantity),
        minQuantity = FormFieldModel(validator: Validators.threshold, initialValue: minQuantity);

  factory VariantRowModel.fromDraft(Map<String, dynamic> json) => VariantRowModel(
        name: '${json['name'] ?? ''}',
        sku: '${json['sku'] ?? ''}',
        costPrice: '${json['costPrice'] ?? '0'}',
        sellingPrice: '${json['sellingPrice'] ?? '0'}',
        quantity: '${json['quantity'] ?? '0'}',
        minQuantity: '${json['minQuantity'] ?? '0'}',
      );

  /// Required — the web labels it `Name *`, and the backend refuses a variant
  /// without one.
  final FormFieldModel name;
  final FormFieldModel sku;
  final FormFieldModel costPrice;
  final FormFieldModel sellingPrice;
  final FormFieldModel quantity;
  final FormFieldModel minQuantity;

  /// Set once the backend has created this variant, so a retry after a
  /// partial failure does not send it twice.
  String? createdId;

  List<FormFieldModel> get fields => [name, sku, costPrice, sellingPrice, quantity, minQuantity];

  bool get isValid => fields.every((field) => field.isValid);

  Map<String, String> toDraft() => {
        'name': name.value,
        'sku': sku.value,
        'costPrice': costPrice.value,
        'sellingPrice': sellingPrice.value,
        'quantity': quantity.value,
        'minQuantity': minQuantity.value,
      };

  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
  }
}

/// `18 — Ajouter un produit`.
///
/// The full create form, against `T3 — Produit`'s shortened one: the same six
/// fields plus the alert threshold, a category, a unit and the variants.
/// Same repository call — the tutorial's product is a real product, it simply
/// leaves the optional half of the form blank.
///
/// **Where this differs from the tutorial's view model, and why:**
///
/// - The tutorial treats a duplicate SKU as *success* — it asked the merchant
///   to have a product and a taken SKU means one is already there. Here it is
///   a plain error the merchant must fix, so nothing branches on it.
/// - Quantity stops being required when [hasVariants] is on, because the
///   server's own rule does: `quantity > 0 unless hasVariants is truthy`.
///   Keeping the client rule stricter than the server's would refuse a form
///   the backend would have accepted.
///
/// **Variants follow the web's `products/page.tsx`:** the product is created
/// with a quantity of 0, then each variant with `POST …/variants`; the backend
/// marks the product and sums its stock. Three guards the web lacks, because
/// each loses work there: a name on every row, no two rows with the same name
/// (the backend's unique rule, which fails the web mid-save), and at least one
/// variant when the box is ticked (otherwise the product is saved with no
/// stock and no variants). A variant failing after the product exists does not
/// re-create the product on retry — only the missing variants are sent.
class AddProductViewModel extends FormViewModel {
  AddProductViewModel({
    required ProductRepository products,
    required CatalogueRepository catalogue,
    FormDraftStore? drafts,
  })  : _products = products,
        _catalogue = catalogue {
    attachFields();
    final saved = keepDraft(drafts, 'addProduct', {
      'name': name,
      'sku': sku,
      'description': description,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'quantity': quantity,
      'minQuantity': minQuantity,
    });
    // The pickers' and the checkbox's choices. The ids came back from the
    // lookup lists moments ago, so they resolve again once [loadOptions]
    // refills them.
    _categoryId = _nonEmpty(saved['categoryId']);
    _unitId = _nonEmpty(saved['unitId']);
    _hasVariants = saved['hasVariants'] == 'true';
    final savedRows = saved['variants'];
    if (savedRows != null && savedRows.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedRows);
        if (decoded is List) {
          for (final row in decoded.whereType<Map<String, dynamic>>()) {
            _attachRow(VariantRowModel.fromDraft(row));
          }
        }
      } on FormatException {
        // A draft that does not parse is dropped; the rows start empty.
      }
    }
  }

  final ProductRepository _products;
  final CatalogueRepository _catalogue;

  final name = FormFieldModel(validator: Validators.name);
  final sku = FormFieldModel(validator: Validators.name);
  final description = FormFieldModel(validator: Validators.optional);
  final costPrice = FormFieldModel(validator: Validators.price);

  /// Cross-field: the backend refuses a selling price below the cost price, so
  /// the form says so before the round trip rather than after it.
  late final sellingPrice = FormFieldModel(
    validator: Validators.sellingPrice(() => costPrice.value),
  );

  /// Required — unless the product has variants, which carry their own stock.
  /// The rule reads the flag live rather than being swapped on toggle, so
  /// ticking the box clears the error immediately.
  late final quantity = FormFieldModel(
    validator: (value) => _hasVariants ? null : Validators.quantity(value),
  );

  /// The low-stock threshold. Optional, and legitimately `0` — which is the
  /// server's own default and means "no threshold", so it cannot use
  /// [Validators.quantity]'s must-be-positive rule.
  final minQuantity = FormFieldModel(validator: Validators.threshold);

  @override
  List<FormFieldModel> get fields => [
        name,
        sku,
        description,
        costPrice,
        sellingPrice,
        quantity,
        minQuantity,
      ];

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

  AppException? _submitError;

  /// Why the last attempt failed, kept as the exception rather than a string
  /// so the screen can read its `fields` as well as its message.
  AppException? get submitError => _submitError;

  /// The server's own message for each input it faulted, keyed by the field
  /// name **as the request sent it** — `sku`, `costPrice`, `quantity`.
  Map<String, String> get serverFieldErrors =>
      _submitError?.fieldMessages ?? const {};

  Product? _created;

  /// The product, once the backend has created it — also after a variant
  /// failed, which is what makes a retry send only the variants.
  Product? get created => _created;

  /// The two lookup lists, fetched together and independently of each other.
  ///
  /// Neither failure is worth surfacing: both fields are optional, and an
  /// empty picker is the same experience as a merchant who has created no
  /// categories yet. The form stays usable either way, which is the point —
  /// a product can be created with neither.
  Future<void> loadOptions() async {
    final results = await Future.wait([
      _catalogue.categories(),
      _catalogue.units(),
    ]);
    if (isDisposed) return;

    if (results[0] case Success(:final value)) {
      _categories = value as List<ProductCategory>;
    }
    if (results[1] case Success(:final value)) {
      _units = value as List<ProductUnit>;
    }
    safeNotify();
  }

  void setCategory(String? id) {
    if (_categoryId == id) return;
    _categoryId = id;
    saveDraft();
    safeNotify();
  }

  void setUnit(String? id) {
    if (_unitId == id) return;
    _unitId = id;
    saveDraft();
    safeNotify();
  }

  void toggleHasVariants(bool value) {
    if (_hasVariants == value) return;
    _hasVariants = value;
    saveDraft();
    safeNotify();
  }

  // ---- Variants ----

  final List<VariantRowModel> _variants = [];
  List<VariantRowModel> get variants => List.unmodifiable(_variants);

  /// The web's "Total qty": `parseInt(quantity) || 0` over every row.
  int get variantTotalQuantity =>
      _variants.fold(0, (sum, row) => sum + (int.tryParse(row.quantity.value.trim()) ?? 0));

  /// The web's "Add Variant". Returns the row so the screen can focus its name.
  VariantRowModel addVariant() {
    final row = VariantRowModel();
    _attachRow(row);
    saveDraft();
    safeNotify();
    return row;
  }

  /// The web's trash button. A row the backend already created stays: it
  /// exists, and removing it here would not remove it there.
  void removeVariant(VariantRowModel row) {
    if (row.createdId != null || !_variants.remove(row)) return;
    saveDraft();
    safeNotify();
    // Its fields are still on screen this frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  void _attachRow(VariantRowModel row) {
    _variants.add(row);
    for (final field in row.fields) {
      field.controller.addListener(() {
        if (field.consumeTextChange()) {
          saveDraft();
          safeNotify();
        }
      });
      field.focusNode.addListener(safeNotify);
    }
  }

  bool _variantsAttempted = false;

  /// The form's visibility rule, for a variant field: on focus, or after a
  /// submit that found a problem.
  FieldError? variantFieldError(FormFieldModel field) {
    final error = field.error;
    if (error == null) return null;
    return (field.hasFocus || _variantsAttempted) ? error : null;
  }

  /// A row repeating an earlier row's name. The backend keeps names unique per
  /// product (case-insensitively, as its collation compares them), so the web
  /// fails halfway through saving on exactly this.
  bool isDuplicateName(VariantRowModel row) {
    final key = row.name.value.trim().toLowerCase();
    if (key.isEmpty) return false;
    for (final other in _variants) {
      if (identical(other, row)) return false;
      if (other.name.value.trim().toLowerCase() == key) return true;
    }
    return false;
  }

  bool showDuplicate(VariantRowModel row) =>
      isDuplicateName(row) && (row.name.hasFocus || _variantsAttempted);

  /// The box is ticked and no variant was added.
  bool get showMissingVariants => _variantsAttempted && _hasVariants && _variants.isEmpty;

  bool _checkVariants({required bool moveFocus}) {
    if (!_hasVariants) {
      _variantsAttempted = false;
      return true;
    }
    final ok = _variants.isNotEmpty && _variants.every((row) => row.isValid && !isDuplicateName(row));
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

  @override
  Map<String, String> get draftExtras => {
        'categoryId': _categoryId ?? '',
        'unitId': _unitId ?? '',
        'hasVariants': '$_hasVariants',
        'variants': jsonEncode([for (final row in _variants) row.toDraft()]),
      };

  static String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;

  /// The backend's own limits for one upload (live docs): 10 files, 5 MB
  /// each, accepted by extension. It answers a breach with a generic 500, so
  /// the form refuses those photos up front instead.
  static const maxPhotos = 10;
  static const maxPhotoBytes = 5 * 1024 * 1024;
  static const photoExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  /// Photos picked for the product. They are uploaded once it exists: the
  /// backend attaches images to a product id, so they cannot travel with the
  /// create call.
  final List<ProductPhoto> _photos = [];
  List<ProductPhoto> get photos => List.unmodifiable(_photos);

  /// Adds what passes the limits and says what did not.
  Set<PhotoRejection> addPhotos(Iterable<ProductPhoto> picked) {
    final rejected = <PhotoRejection>{};
    for (final photo in picked) {
      if (!photoExtensions.contains(photo.extension)) {
        rejected.add(PhotoRejection.wrongType);
      } else if (photo.bytes.length > maxPhotoBytes) {
        rejected.add(PhotoRejection.tooLarge);
      } else if (_photos.length >= maxPhotos) {
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

  /// The form holds something back would throw away: a typed field, a picked
  /// category or unit, the variants flag, or a photo. A draft restored after a
  /// splash replay counts too, because it is the merchant's own typing.
  ///
  /// False once [created] is set. The product exists even when its photos
  /// failed and the screen stays up, so "the product you started will be
  /// lost" would be untrue, and could prompt a duplicate.
  bool get hasChanges =>
      _created == null &&
      (fields.any((field) => field.value.trim().isNotEmpty) ||
          _categoryId != null ||
          _unitId != null ||
          _hasVariants ||
          _photos.isNotEmpty);

  /// True when the product was created but its photos could not be uploaded.
  bool _photosFailed = false;
  bool get photosFailed => _photosFailed;

  /// Recomputed on every keystroke in the cost field, because the selling
  /// price's validity depends on it.
  void onCostPriceChanged() => safeNotify();

  /// Validates, then creates. Returns the product once it and all its
  /// variants exist, null otherwise.
  ///
  /// Nothing here navigates — the screen does.
  Future<Product?> submitAndCreate() async {
    _submitError = null;
    final fieldsOk = submit();
    final variantsOk = _checkVariants(moveFocus: fieldsOk);
    if (!fieldsOk || !variantsOk) return null;

    return run(
      () async {
        var product = _created;
        if (product == null) {
          _photosFailed = false;
          final created = await _products.create(
            sku: sku.value,
            name: name.value,
            description: description.value,
            // Non-null: the validators above already refused anything unparseable.
            costPrice: Validators.parseAmount(costPrice.value)!,
            sellingPrice: Validators.parseAmount(sellingPrice.value)!,
            // Zero when the product has variants, which is the one case the
            // server accepts it — the variants hold the stock.
            quantity: _hasVariants ? 0 : _asInt(quantity.value),
            minQuantity: _asInt(minQuantity.value),
            // Only ever an id that came back from `/categories` and `/units`. The
            // controller checks neither existence nor ownership, so a made-up id
            // is a 500 rather than a 400.
            categoryId: _categoryId,
            unitId: _unitId,
            hasVariants: _hasVariants,
          );
          product = created.valueOrNull;
          if (product == null) return created;
          _created = product;
          // Photos attach to a product id, so they can only follow the create.
          // A failed upload does not undo it: the product exists either way.
          if (_photos.isNotEmpty) {
            final upload = await _products.uploadImages(productId: product.id, photos: _photos);
            _photosFailed = upload.isFailure;
          }
        }

        if (_hasVariants) {
          // One at a time, in the rows' order, as the web does.
          for (final row in _variants) {
            if (row.createdId != null) continue;
            final result = await _products.createVariant(
              productId: product.id,
              name: row.name.value,
              sku: row.sku.value,
              costPrice: Validators.parseAmount(row.costPrice.value) ?? 0,
              sellingPrice: Validators.parseAmount(row.sellingPrice.value) ?? 0,
              quantity: _asInt(row.quantity.value),
              minQuantity: _asInt(row.minQuantity.value),
            );
            final variant = result.valueOrNull;
            if (variant == null) return Result<Product>.failure(result.errorOrNull!);
            row.createdId = variant.id;
          }
        }
        return Result<Product>.success(product);
      },
      onError: (error) => _submitError = error,
      tag: 'createProduct',
    );
  }

  /// An empty optional number field means zero, not a parse failure — the
  /// threshold is allowed to be blank and the server defaults it to 0.
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

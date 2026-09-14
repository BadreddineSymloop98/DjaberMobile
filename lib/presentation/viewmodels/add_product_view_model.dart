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

/// `18 — Ajouter un produit`.
///
/// The full create form, against `T3 — Produit`'s shortened one: the same six
/// fields plus the alert threshold, a category, a unit and the variants flag.
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

  @override
  Map<String, String> get draftExtras => {
        'categoryId': _categoryId ?? '',
        'unitId': _unitId ?? '',
        'hasVariants': '$_hasVariants',
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

  /// True when the product was created but its photos could not be uploaded.
  bool _photosFailed = false;
  bool get photosFailed => _photosFailed;

  /// Recomputed on every keystroke in the cost field, because the selling
  /// price's validity depends on it.
  void onCostPriceChanged() => safeNotify();

  /// Validates, then creates. Returns the product on success, null otherwise.
  ///
  /// Nothing here navigates — the screen does.
  Future<Product?> submitAndCreate() async {
    _submitError = null;
    _photosFailed = false;
    if (!submit()) return null;

    final product = await run(
      () async {
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
        // Photos attach to a product id, so they can only follow the create.
        // A failed upload does not undo it: the product exists either way.
        final value = created.valueOrNull;
        if (value != null && _photos.isNotEmpty) {
          final upload = await _products.uploadImages(
            productId: value.id,
            photos: _photos,
          );
          _photosFailed = upload.isFailure;
        }
        return created;
      },
      onError: (error) => _submitError = error,
      tag: 'createProduct',
    );

    if (product != null) _created = product;
    return product;
  }

  /// An empty optional number field means zero, not a parse failure — the
  /// threshold is allowed to be blank and the server defaults it to 0.
  static int _asInt(String value) =>
      int.tryParse(value.trim().replaceAll(' ', '')) ?? 0;
}

import '../../core/error/app_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'form_field_model.dart';

/// The form on `T3 — Produit`, and the call that creates the product.
///
/// Six fields, which are the five the backend requires on creation plus the
/// description — the one optional field the frame keeps, because the web's own
/// placeholder says the agent reads it to sell the product. Category and unit
/// are optional on the web too, which is what makes this shortened form
/// produce a complete product rather than a stub.
class TutorialProductViewModel extends FormViewModel {
  TutorialProductViewModel({required ProductRepository products})
      : _products = products {
    attachFields();
  }

  final ProductRepository _products;

  final name = FormFieldModel(validator: Validators.name);
  final sku = FormFieldModel(validator: Validators.name);
  final description = FormFieldModel(validator: Validators.optional);
  final costPrice = FormFieldModel(validator: Validators.price);

  /// Cross-field: the backend refuses a selling price below the cost price, so
  /// the form says so before the round trip rather than after it.
  late final sellingPrice = FormFieldModel(
    validator: Validators.sellingPrice(() => costPrice.value),
  );

  final quantity = FormFieldModel(validator: Validators.quantity);

  @override
  List<FormFieldModel> get fields =>
      [name, sku, description, costPrice, sellingPrice, quantity];

  /// The created product, once the call has succeeded. `T6 — Prêt` shows what
  /// was actually created, so it is kept rather than discarded.
  Product? _created;
  Product? get created => _created;

  /// Why the last attempt failed.
  ///
  /// Kept as the exception rather than a string so the screen can read more
  /// than its message: the error contract puts a stable `code` on it and, on
  /// a 400, names the exact inputs at fault. Shown above the button, not as a
  /// toast, matching the auth screens.
  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// True when the server refused because a product with that SKU already
  /// exists.
  ///
  /// Not an error for this step. `T3` asks the merchant to create their first
  /// product; a taken SKU means one is already there, so the step is done and
  /// the flow should move on rather than blocking. Before the error contract
  /// this was an untyped 400 carrying the English sentence "SKU already
  /// exists", which could only be matched on text; it is now a 409 with the
  /// stable code below, which is what makes this safe to branch on.
  bool _alreadyExists = false;
  bool get alreadyExists => _alreadyExists;

  /// The server's own message for each input it faulted, keyed by the field
  /// name **as the request sent it** — `sku`, `costPrice`, `quantity`.
  ///
  /// Already translated, so it goes straight onto the control. This is the
  /// half of a 400 the app used to throw away: it showed the summary line and
  /// left the merchant to guess which of six fields the server meant.
  Map<String, String> get serverFieldErrors =>
      _submitError?.fieldMessages ?? const {};

  /// Recomputed on every keystroke in the cost field, because the selling
  /// price's validity depends on it.
  void onCostPriceChanged() => safeNotify();

  /// Every field, by the key its value is kept under in a draft.
  Map<String, FormFieldModel> get _draftFields => {
        'name': name,
        'sku': sku,
        'description': description,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
      };

  /// What has been typed and not sent, for `TutorialViewModel.saveDraft` to
  /// hold while this step's screen is gone.
  Map<String, String> get draft => {
        for (final entry in _draftFields.entries) entry.key: entry.value.value,
      };

  /// Puts back a [draft]. Keys this form does not know are ignored.
  void restore(Map<String, String> draft) {
    for (final entry in _draftFields.entries) {
      final value = draft[entry.key];
      if (value != null) entry.value.controller.text = value;
    }
  }

  /// Validates, then creates. Returns the product on success, null otherwise.
  ///
  /// Nothing here navigates — the screen does, the way every other call site
  /// in this app states its own destination.
  Future<Product?> submitAndCreate() async {
    _submitError = null;
    _alreadyExists = false;
    if (!submit()) return null;

    final product = await run(
      () => _products.create(
        sku: sku.value,
        name: name.value,
        description: description.value,
        // Non-null: the validators above already refused anything unparseable.
        costPrice: Validators.parseAmount(costPrice.value)!,
        sellingPrice: Validators.parseAmount(sellingPrice.value)!,
        quantity: int.parse(quantity.value.trim().replaceAll(' ', '')),
      ),
      onError: (error) {
        if (error.code == 'PRODUCT_SKU_ALREADY_EXISTS') {
          // Left out of `_submitError` on purpose: the screen advances on
          // this, so showing it as a failure above the button would contradict
          // the navigation that follows.
          _alreadyExists = true;
          return;
        }
        _submitError = error;
      },
      tag: 'createProduct',
    );

    if (product != null) _created = product;
    return product;
  }
}

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

  /// Why the last attempt failed, unlocalised.
  ///
  /// Kept as the exception rather than a string so the screen can decide: a
  /// transport failure gets the app's own message, while a 400 carries the
  /// backend's own sentence — "SKU already exists", "Selling price must be
  /// greater than or equal to cost price" — which is more use to the merchant
  /// than a generic apology. Shown above the button, not as a toast, matching
  /// the auth screens.
  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// Recomputed on every keystroke in the cost field, because the selling
  /// price's validity depends on it.
  void onCostPriceChanged() => safeNotify();

  /// Validates, then creates. Returns the product on success, null otherwise.
  ///
  /// Nothing here navigates — the screen does, the way every other call site
  /// in this app states its own destination.
  Future<Product?> submitAndCreate() async {
    _submitError = null;
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
      onError: (error) => _submitError = error,
      tag: 'createProduct',
    );

    if (product != null) _created = product;
    return product;
  }
}

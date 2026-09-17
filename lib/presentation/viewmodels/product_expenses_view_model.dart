import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/product.dart';
import '../../data/models/product_expense.dart';
import '../../data/repositories/product_repository.dart';
import 'base_view_model.dart';

/// `Product expenses panel` — the web's side panel on
/// `/dashboard/stock/products`, a full screen here.
///
/// Three reads make the screen, and they are **not** equal:
///
/// - the product, for its name — required, because a screen with no title is
///   not a screen;
/// - the expenses list and the margin summary, which are what the merchant
///   came for.
///
/// The margins are read from `GET …/margins` and never recomputed here. The
/// backend's formula floors the quantity at 1 so it cannot divide by zero, and
/// re-deriving that in Dart would drift the day the formula changes. It also
/// means both reads have to be refreshed after every write — adding a 2 500 DA
/// expense changes `trueCost` and `netMargin`, not just the list.
class ProductExpensesViewModel extends BaseViewModel {
  ProductExpensesViewModel({
    required ProductRepository products,
    required this.productId,
  }) : _products = products;

  final ProductRepository _products;
  final String productId;

  Product? _product;
  Product? get product => _product;

  List<ProductExpense> _expenses = const [];
  List<ProductExpense> get expenses => _expenses;

  ProductMargins? _margins;
  ProductMargins? get margins => _margins;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Everything the screen shows, in one pass.
  ///
  /// Silent after the first load, so adding an expense does not blank the list
  /// that is already on screen.
  Future<void> load() async {
    if (!_loaded) clearError();
    final results = await Future.wait([
      _products.get(productId),
      _products.expenses(productId),
      _products.margins(productId),
    ]);
    if (isDisposed) return;

    switch (results[0]) {
      case Success(:final value):
        _product = value as Product;
      case Failure(:final error):
        // Only fatal on the first load. Later, the screen keeps what it has.
        if (!_loaded) {
          setError(error);
          safeNotify();
          return;
        }
    }
    if (results[1] case Success(:final value)) {
      _expenses = value as List<ProductExpense>;
    }
    if (results[2] case Success(:final value)) {
      _margins = value as ProductMargins;
    }
    _loaded = true;
    setState(ViewState.ready);
    safeNotify();
  }

  // ---- The add form ----

  /// The web's default, and the first option its select offers.
  ExpenseCategory _category = ExpenseCategory.marketing;
  ExpenseCategory get category => _category;

  final amount = TextEditingController();
  final description = TextEditingController();
  final amountFocus = FocusNode();
  final descriptionFocus = FocusNode();

  /// The web's *fixed* / *per unit* toggle beside the amount. False — a fixed
  /// total — is the default there and on the backend.
  bool _isPerUnit = false;
  bool get isPerUnit => _isPerUnit;

  void setCategory(ExpenseCategory value) {
    if (_category == value) return;
    _category = value;
    safeNotify();
  }

  void togglePerUnit() {
    _isPerUnit = !_isPerUnit;
    safeNotify();
  }

  bool _attempted = false;

  /// The amount, or null when it is empty or unreadable.
  double? get _typedAmount => Validators.parseAmount(amount.text);

  /// The backend refuses anything at or below zero with a 400.
  bool get showAmountError =>
      _attempted && (_typedAmount == null || _typedAmount! <= 0);

  AppException? _submitError;
  AppException? get submitError => _submitError;

  bool _adding = false;

  /// Separate from [isBusy], which a delete also sets: the two controls have
  /// their own spinners and must not disable each other.
  bool get isAdding => _adding;

  /// Creates the expense, then re-reads the list and the margins.
  ///
  /// Returns true on success, so the screen can clear the form and say so.
  Future<bool> addExpense() async {
    _attempted = true;
    _submitError = null;
    final value = _typedAmount;
    if (value == null || value <= 0) {
      amountFocus.requestFocus();
      safeNotify();
      return false;
    }

    _adding = true;
    safeNotify();
    final result = await _products.addExpense(
      productId: productId,
      category: _category,
      amount: value,
      isPerUnit: _isPerUnit,
      description: description.text,
    );
    if (isDisposed) return false;
    _adding = false;

    if (result.errorOrNull case final error?) {
      _submitError = error;
      safeNotify();
      return false;
    }

    amount.clear();
    description.clear();
    _attempted = false;
    // The margin figures moved with the list, so both are re-read.
    await load();
    return true;
  }

  String? _deletingId;

  /// The expense currently being removed, so its row can show it.
  String? get deletingId => _deletingId;

  /// Removes an expense — a **hard** delete on the backend — then refreshes.
  Future<bool> deleteExpense(ProductExpense expense) async {
    if (_deletingId != null) return false;
    _submitError = null;
    _deletingId = expense.id;
    safeNotify();

    final result = await _products.deleteExpense(
      productId: productId,
      expenseId: expense.id,
    );
    if (isDisposed) return false;
    _deletingId = null;

    if (result.errorOrNull case final error?) {
      _submitError = error;
      safeNotify();
      return false;
    }
    await load();
    return true;
  }

  @override
  void dispose() {
    amount.dispose();
    description.dispose();
    amountFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }
}

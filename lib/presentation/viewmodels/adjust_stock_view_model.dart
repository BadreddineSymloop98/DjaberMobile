import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'base_view_model.dart';

/// One adjustable line: the product itself, or one of its variants.
///
/// The two forms on the sheet are the same three controls — a type, a quantity
/// and a reason — so they are one class rather than two. What differs is only
/// how it is sent, which [AdjustStockViewModel] decides from [variantId].
class AdjustRow {
  AdjustRow({required this.variantId, required this.label, required this.currentQuantity});

  /// Null for the product's own line.
  final String? variantId;

  /// The variant's name, or the product's — what the card's header shows.
  final String label;

  /// Stock before the adjustment, shown as `QTÉ : n` and used to keep an
  /// outgoing movement within what is actually there.
  final int currentQuantity;

  /// Starts on *Entrée (+)*, as the web's form does.
  StockAdjustType type = StockAdjustType.stockIn;

  final quantity = TextEditingController();
  final reason = TextEditingController();

  /// Owned here rather than by the card, which is rebuilt on every keystroke.
  final quantityFocus = FocusNode();
  final reasonFocus = FocusNode();

  /// Set once this line has been sent, so a retry after a later line failed
  /// does not apply it twice — an `in` of 5 run twice is 10 units the merchant
  /// never received.
  bool applied = false;

  /// The typed quantity, or null when the field is empty or unreadable.
  int? get typedQuantity {
    final text = quantity.text.trim().replaceAll(' ', '');
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  /// Whether this line is sent. A line left blank is skipped rather than
  /// refused, which is what makes the variant sheet usable — a merchant adjusts
  /// one size out of five.
  ///
  /// **Diverges from the web on one value, on purpose.** The web counts a line
  /// only when its quantity is above zero, so *Fixer* to `0` silently did
  /// nothing and the sheet answered "enter a quantity" — refusing a perfectly
  /// ordinary request, "this size is sold out". Here `0` counts for *Fixer*.
  /// For *Entrée* and *Sortie* it still does not: moving zero units is not an
  /// adjustment, and the backend refuses it.
  bool get isFilled {
    final typed = typedQuantity;
    if (typed == null) return false;
    return type == StockAdjustType.set ? typed >= 0 : typed > 0;
  }

  /// An outgoing movement larger than the stock on hand. The backend answers
  /// `Insufficient stock` with a 400; saying so before the round trip keeps the
  /// other lines of a multi-variant adjustment from being sent at all.
  bool get exceedsStock =>
      type == StockAdjustType.stockOut && (typedQuantity ?? 0) > currentQuantity;

  /// What this line would leave on the shelf, for the card's preview.
  int get resultingQuantity => switch (type) {
        StockAdjustType.stockIn => currentQuantity + (typedQuantity ?? 0),
        StockAdjustType.stockOut => currentQuantity - (typedQuantity ?? 0),
        StockAdjustType.set => typedQuantity ?? currentQuantity,
      };

  void dispose() {
    quantity.dispose();
    reason.dispose();
    quantityFocus.dispose();
    reasonFocus.dispose();
  }
}

/// `Adjust stock` — the web's Adjust Stock modal, as a sheet over `17a`.
///
/// **Which form appears is the backend's decision, not a preference.**
/// `POST /products/{id}/adjust` refuses a product with variants outright (400,
/// *"This product has variants. Adjust stock at the variant level."*), so a
/// variant product gets one card per variant and a plain one gets a single
/// card. That is also what the web does and what the Figma frame draws.
///
/// **Nothing here is a partial edit of a form** — every line is its own request
/// and its own stock movement. So the sheet sends only the lines that were
/// filled in, marks each as it succeeds, and a failure part-way leaves the rest
/// to a second tap rather than replaying what already moved.
class AdjustStockViewModel extends BaseViewModel {
  AdjustStockViewModel({required ProductRepository products, required Product product})
      : _products = products,
        _product = product {
    _rows = product.hasVariants
        ? [
            // Inactive variants included: the docs say an adjustment applies to
            // one, and the merchant can see it on `17a` — hiding it here would
            // be the one place its stock cannot be corrected.
            for (final variant in product.variants)
              AdjustRow(
                variantId: variant.id,
                label: variant.name,
                currentQuantity: variant.quantity,
              ),
          ]
        : [
            AdjustRow(
              variantId: null,
              label: product.name,
              currentQuantity: product.quantity,
            ),
          ];
    for (final row in _rows) {
      row.quantity.addListener(safeNotify);
    }
  }

  final ProductRepository _products;
  final Product _product;

  Product get product => _product;

  late final List<AdjustRow> _rows;
  List<AdjustRow> get rows => List.unmodifiable(_rows);

  bool get isVariantForm => _product.hasVariants;

  void setType(AdjustRow row, StockAdjustType type) {
    if (row.type == type) return;
    row.type = type;
    safeNotify();
  }

  bool _attempted = false;

  /// True once the button has been pressed with nothing filled in, which is the
  /// only way to reach this sheet's empty state.
  bool get showNothingToApply => _attempted && !_rows.any((row) => row.isFilled);

  /// A filled line asking for more than the stock holds. Shown on the card, not
  /// in the summary line, so the merchant sees which one.
  bool showsExceeds(AdjustRow row) => row.isFilled && row.exceedsStock;

  bool get _hasBlocking => _rows.any((row) => row.isFilled && row.exceedsStock);

  /// Enabled as soon as one line is usable — the button is not a validity
  /// light, it is the action, and pressing it with nothing typed explains why
  /// rather than doing nothing.
  bool get canApply => !isBusy;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// Sends every filled line. Returns true when all of them went through.
  ///
  /// Nothing here navigates — the sheet does, and the screen underneath
  /// reloads.
  Future<bool> apply() async {
    _attempted = true;
    _submitError = null;
    if (!_rows.any((row) => row.isFilled) || _hasBlocking) {
      safeNotify();
      return false;
    }

    final result = await run<bool>(
      () async {
        for (final row in _rows) {
          if (!row.isFilled || row.applied) continue;
          var type = row.type;
          var quantity = row.typedQuantity!;
          final variantId = row.variantId;

          // *Fixer* to 0 on a product without variants. The variant route
          // accepts `quantity: 0`, but the product route rejects it (400,
          // "Type and quantity are required"). Taking out everything on hand
          // leaves the same stock and writes the same signed movement.
          if (variantId == null && type == StockAdjustType.set && quantity == 0) {
            if (row.currentQuantity <= 0) {
              // Already empty: nothing to move, and nothing to report.
              row.applied = true;
              continue;
            }
            type = StockAdjustType.stockOut;
            quantity = row.currentQuantity;
          }

          final Result<Object> sent = variantId == null
              ? await _products.adjustStock(
                  productId: _product.id,
                  type: type,
                  quantity: quantity,
                  reason: row.reason.text,
                )
              : await _products.adjustVariantStock(
                  productId: _product.id,
                  variantId: variantId,
                  type: type,
                  quantity: quantity,
                  reason: row.reason.text,
                );

          if (sent.errorOrNull case final error?) {
            return Result<bool>.failure(error);
          }
          // Marked the moment it lands, so a failure on the next variant does
          // not re-apply this one.
          row.applied = true;
        }
        return const Result<bool>.success(true);
      },
      onError: (error) => _submitError = error,
      tag: 'adjustStock',
    );

    return result ?? false;
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }
}

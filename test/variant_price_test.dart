import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/core/utils/validators.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/presentation/viewmodels/add_product_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/edit_product_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_repositories.dart';

/// `18 — Ajouter un produit`: a variant's selling price may not sit below its
/// cost price — the rule the product itself already has. The variant endpoint
/// does not enforce it (live docs), so only the form can.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  VariantRowModel row({String cost = '0', String price = '0'}) {
    // Named, so the only rule that can fail is the one under test.
    final r = VariantRowModel(name: 'Rouge', costPrice: cost, sellingPrice: price);
    addTearDown(r.dispose);
    return r;
  }

  group('one variant row', () {
    test('a price below the cost is refused', () {
      final r = row(cost: '1500', price: '1200');
      expect(r.sellingPrice.error, FieldError.belowCostPrice);
      expect(r.isValid, isFalse);
    });

    test('a price equal to or above the cost is fine', () {
      expect(row(cost: '1500', price: '1500').isValid, isTrue);
      expect(row(cost: '1500', price: '2000').isValid, isTrue);
    });

    test('a new row, 0 and 0, is still valid', () {
      expect(row().isValid, isTrue);
    });

    test('the loose forms a merchant types are compared as numbers', () {
      expect(row(cost: '1 500,50', price: '1 500,25').sellingPrice.error, FieldError.belowCostPrice);
      expect(row(cost: '900', price: '1 000').isValid, isTrue);
    });

    test('an empty or unreadable cost leaves the price alone', () {
      expect(row(cost: '', price: '100').sellingPrice.error, isNull);
      expect(row(cost: 'abc', price: '100').sellingPrice.error, isNull);
    });

    test('raising the cost afterwards makes the price wrong', () {
      final r = row(cost: '1000', price: '1200');
      expect(r.isValid, isTrue);
      r.costPrice.controller.text = '1300';
      expect(r.sellingPrice.error, FieldError.belowCostPrice);
    });

    test('a draft restored with a bad pair is caught too', () {
      final r = VariantRowModel.fromDraft({'name': 'Rouge', 'costPrice': '800', 'sellingPrice': '500'});
      addTearDown(r.dispose);
      expect(r.sellingPrice.error, FieldError.belowCostPrice);
    });
  });

  group('saving', () {
    test('nothing is sent while a variant is priced below its cost', () async {
      final products = _CountingProducts();
      final form = AddProductViewModel(products: products, catalogue: FakeCatalogueRepository());
      addTearDown(form.dispose);
      form.name.controller.text = 'Robe satin';
      form.sku.controller.text = 'ROBE-01';
      form.costPrice.controller.text = '1000';
      form.sellingPrice.controller.text = '1500';
      form.toggleHasVariants(true);
      final variant = form.addVariant();
      variant.name.controller.text = 'Rouge';
      variant.costPrice.controller.text = '1000';
      variant.sellingPrice.controller.text = '800';

      final created = await form.submitAndCreate();

      expect(created, isNull);
      expect(products.creates, 0);
      expect(form.variantFieldError(variant.sellingPrice), FieldError.belowCostPrice);
    });
  });

  // `Modifier le produit` has its own row model — a saved variant locks its
  // quantity — and the same rule must hold there.
  group('edit product', () {
    EditVariantRow editRow({String cost = '0', String price = '0'}) {
      final r = EditVariantRow(name: 'Rouge', costPrice: cost, sellingPrice: price);
      addTearDown(r.dispose);
      return r;
    }

    test('a price below the cost is refused', () {
      expect(editRow(cost: '1500', price: '1200').sellingPrice.error, FieldError.belowCostPrice);
    });

    test('equal, above, and a new 0 / 0 row are fine', () {
      expect(editRow(cost: '1500', price: '1500').isValid, isTrue);
      expect(editRow(cost: '1500', price: '2000').isValid, isTrue);
      expect(editRow().isValid, isTrue);
    });

    test('a saved variant already priced under cost is caught when loaded', () {
      final r = EditVariantRow.of(
        const ProductVariant(id: 'v-1', name: 'Rouge', costPrice: 800, sellingPrice: 500),
      );
      addTearDown(r.dispose);
      expect(r.sellingPrice.error, FieldError.belowCostPrice);
    });

    test('raising the cost afterwards makes the price wrong', () {
      final r = editRow(cost: '1000', price: '1200');
      r.costPrice.controller.text = '1300';
      expect(r.sellingPrice.error, FieldError.belowCostPrice);
    });

    test('the save is refused, with the error on the price', () {
      final form = EditProductViewModel(
        products: FakeProductRepository(),
        catalogue: FakeCatalogueRepository(),
        productId: 'p-1',
      );
      addTearDown(form.dispose);
      form.name.controller.text = 'Robe satin';
      form.sku.controller.text = 'ROBE-01';
      form.toggleHasVariants(true);
      final variant = form.addVariant();
      variant.name.controller.text = 'Rouge';
      variant.costPrice.controller.text = '1000';
      variant.sellingPrice.controller.text = '800';

      expect(form.validateForSave(), isFalse);
      expect(form.variantFieldError(variant.sellingPrice), FieldError.belowCostPrice);
    });
  });
}

class _CountingProducts extends FakeProductRepository {
  int creates = 0;

  @override
  Future<Result<Product>> create({
    required String sku,
    required String name,
    String? description,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    int minQuantity = 0,
    String? categoryId,
    String? unitId,
    bool hasVariants = false,
  }) {
    creates++;
    return super.create(
      sku: sku,
      name: name,
      description: description,
      costPrice: costPrice,
      sellingPrice: sellingPrice,
      quantity: quantity,
      minQuantity: minQuantity,
      categoryId: categoryId,
      unitId: unitId,
      hasVariants: hasVariants,
    );
  }
}

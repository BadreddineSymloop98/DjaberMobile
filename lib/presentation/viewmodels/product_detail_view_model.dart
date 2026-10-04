import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import 'base_view_model.dart';

/// The product detail screen — the web's *Product Details* modal on
/// `/dashboard/stock/products`, which reloads the product with
/// `GET /products/{id}` before showing it (so the variants table lists the
/// inactive ones too).
class ProductDetailViewModel extends BaseViewModel {
  ProductDetailViewModel({required ProductRepository products, required this.productId})
      : _products = products;

  final ProductRepository _products;
  final String productId;

  Product? _product;
  Product? get product => _product;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// Silent after the first load, so a pull to refresh keeps what is shown.
  ///
  /// [withImages] are rows an upload has just confirmed — see
  /// [Product.withImages]. They are merged into whatever this reads, because a
  /// reload fired the instant a save pops can answer before the backend lists
  /// the images it has only just created.
  Future<void> load({List<ProductImage> withImages = const []}) async {
    await run(
      () => _products.get(productId),
      onSuccess: (value) => _product = value.withImages(withImages),
      silent: _loadedOnce,
      tag: 'productDetail',
    );
    _loadedOnce = true;
    safeNotify();
  }
}

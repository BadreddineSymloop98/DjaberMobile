import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:djaber_mobile/app/route_observer.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/products/edit_product_screen.dart';
import 'package:djaber_mobile/presentation/screens/products/product_detail_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/edit_product_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// Adding a photo on the edit form and coming back to the product.
///
/// Reported twice from the handset: *"in edit product, when adding a picture
/// to a product, the screen goes to product details, but the added picture
/// shows only after refreshing."* Reasoning about the code said the flow was
/// sound — it is not, and only driving the two screens on a **real router**
/// shows why, because what breaks is the value a pop carries.
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  const newImage = ProductImage(
    id: 'img-new',
    url: 'https://djaber.test/uploads/products/sac.jpg',
  );

  /// The product as the backend holds it before the edit: no pictures.
  Product bare() => Product.fromJson({
        'id': 'p-1',
        'sku': 'SAC-01',
        'name': 'Sac cuir',
        'costPrice': '1000.00',
        'sellingPrice': '1500.00',
        'quantity': 4,
        'images': <Map<String, dynamic>>[],
      });

  /// Hosts `17a` with the edit route above it, exactly as `router.dart`
  /// declares them: siblings on the root navigator, edit before detail.
  Future<L10n> pump(WidgetTester tester, _Products products) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: Routes.productOf('p-1'),
      // As `router.dart` wires it: the detail screen refreshes off this.
      observers: [appRouteObserver],
      routes: [
        GoRoute(
          path: Routes.productEdit,
          builder: (_, state) =>
              EditProductScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: Routes.product,
          builder: (_, state) =>
              ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(routerHost(
      router,
      session,
      extra: [
        Provider<ProductRepository>.value(value: products),
        Provider<CatalogueRepository>.value(value: FakeCatalogueRepository()),
      ],
    ));
    await tester.pumpAndSettle();
    return L10n.delegate.load(const Locale('fr'));
  }

  /// Opens the edit form, attaches a photo the way the picker would, saves.
  Future<void> addAPhotoAndSave(WidgetTester tester, L10n l10n) async {
    await tester.tap(find.bySemanticsLabel(l10n.productEditTitle).first);
    await tester.pumpAndSettle();
    expect(find.byType(EditProductScreen), findsOneWidget);

    // The picker itself needs a platform channel; what it hands back does not.
    // The bytes go in through the view model exactly as `pickProductPhotos`
    // delivers them.
    final model = tester
        .element(find.descendant(
          of: find.byType(EditProductScreen),
          matching: find.byType(Scaffold),
        ))
        .read<EditProductViewModel>();
    model.addPhotos([
      ProductPhoto(name: 'sac.jpg', bytes: Uint8List.fromList([1, 2, 3])),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.productEditSubmit));
    await tester.pumpAndSettle();
  }

  List<String> shownUrls(WidgetTester tester) => tester
      .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
      .map((image) => image.imageUrl)
      .toList();

  testWidgets('the photo is on the product page the save returns to, without '
      'a pull to refresh', (tester) async {
    // The reload answers without the new row — the worst the backend does, and
    // what the merchant was hitting.
    final products = _Products(bare(), uploaded: const [newImage]);
    final l10n = await pump(tester, products);

    await addAPhotoAndSave(tester, l10n);

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(products.uploads, 1, reason: 'the photo was sent');
    expect(
      shownUrls(tester),
      contains(newImage.url),
      reason: 'the gallery shows the photo that was just added',
    );
  });

  testWidgets('and it refreshes even when the form closes without reporting '
      'anything — the path the pop value never covered', (tester) async {
    // The edit form does not always pop with a value: it can also leave
    // through the router's fallback, which completes no future. The screen
    // used to reload only on that value, so this path left it stale.
    final products = _Products(bare(), uploaded: const [newImage]);
    final l10n = await pump(tester, products);

    await tester.tap(find.bySemanticsLabel(l10n.productEditTitle).first);
    await tester.pumpAndSettle();
    expect(find.byType(EditProductScreen), findsOneWidget);

    // Meanwhile the product gains a photo server-side, as a save would leave
    // it, and the form closes carrying nothing.
    products.serverNowHas([newImage]);
    GoRouter.of(tester.element(find.byType(EditProductScreen))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(shownUrls(tester), contains(newImage.url));
  });

  testWidgets('and when the reload does carry it, it is shown once',
      (tester) async {
    final products = _Products(
      bare(),
      uploaded: const [newImage],
      reloadCarriesUpload: true,
    );
    final l10n = await pump(tester, products);

    await addAPhotoAndSave(tester, l10n);

    expect(shownUrls(tester), [newImage.url]);
  });
}

/// The product endpoints this flow touches, and nothing else.
class _Products extends ProductRepository {
  _Products(
    this._product, {
    this.uploaded = const [],
    this.reloadCarriesUpload = false,
  }) : super(api: apiForTest());

  Product _product;

  /// The product as the backend now holds it — what the next `get` answers.
  void serverNowHas(List<ProductImage> images) =>
      _product = _product.withImages(images);

  /// What `POST …/images` answers with.
  final List<ProductImage> uploaded;

  /// Whether the `GET` that follows already lists those rows. False is the
  /// backend at its slowest, which is the case worth holding the app to.
  final bool reloadCarriesUpload;

  int uploads = 0;

  @override
  Future<Result<Product>> get(String productId) async => Result.success(
        reloadCarriesUpload && uploads > 0
            ? _product.withImages(uploaded)
            : _product,
      );

  @override
  Future<Result<Product>> update(
    String productId, {
    required String sku,
    required String name,
    String? description,
    double? costPrice,
    double? sellingPrice,
    int? minQuantity,
    String? categoryId,
    String? unitId,
  }) async {
    return Result.success(_product);
  }

  @override
  Future<Result<List<ProductImage>>> uploadImages({
    required String productId,
    required List<ProductPhoto> photos,
  }) async {
    uploads++;
    return Result.success(uploaded);
  }
}

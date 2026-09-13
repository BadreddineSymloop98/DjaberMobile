import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/presentation/viewmodels/add_product_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// Photos on `18 — Ajouter un produit`: what the form accepts, and what it
/// sends once the product exists.
void main() {
  ProductPhoto photo(String name, {int bytes = 10}) =>
      ProductPhoto(name: name, bytes: Uint8List(bytes));

  group('the upload request', () {
    test('every photo goes under the one field name "images", with its name',
        () async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 't'});
      final sent = <RequestOptions>[];
      final dio = Dio()
        ..httpClientAdapter = _StubAdapter((options) {
          sent.add(options);
          return ResponseBody.fromString(
            jsonEncode({
              'images': [
                {'id': 'i-1'},
                {'id': 'i-2'},
              ],
            }),
            201,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });
      final repository = ProductRepository(api: apiForTest(dio: dio));

      final result = await repository.uploadImages(
        productId: 'p-1',
        photos: [photo('sac.jpg'), photo('dos.PNG')],
      );

      expect(result.valueOrNull, 2);
      final request = sent.single;
      expect(request.method, 'POST');
      expect(request.path, '/api/user-stock/products/p-1/images');
      final form = request.data as FormData;
      expect(form.files.map((f) => f.key), ['images', 'images']);
      expect(form.files.map((f) => f.value.filename), ['sac.jpg', 'dos.PNG']);
    });
  });

  group('what the form accepts', () {
    AddProductViewModel model() {
      final m = AddProductViewModel(
        products: FakeProductRepository(),
        catalogue: FakeCatalogueRepository(),
      );
      addTearDown(m.dispose);
      return m;
    }

    test('the backend\'s extensions, in any case', () {
      final form = model();
      final rejected = form.addPhotos([
        photo('a.jpg'),
        photo('b.JPEG'),
        photo('c.png'),
        photo('d.webp'),
        photo('e.gif'),
        photo('f.heic'),
        photo('noextension'),
      ]);

      expect(form.photos.length, 5);
      expect(rejected, {PhotoRejection.wrongType});
    });

    test('nothing over 5 MB', () {
      final form = model();
      final rejected = form.addPhotos([
        photo('ok.jpg', bytes: AddProductViewModel.maxPhotoBytes),
        photo('big.jpg', bytes: AddProductViewModel.maxPhotoBytes + 1),
      ]);

      expect(form.photos.single.name, 'ok.jpg');
      expect(rejected, {PhotoRejection.tooLarge});
    });

    test('no more than 10, across several picks', () {
      final form = model();
      form.addPhotos([for (var i = 0; i < 8; i++) photo('$i.jpg')]);
      final rejected =
          form.addPhotos([for (var i = 8; i < 12; i++) photo('$i.jpg')]);

      expect(form.photos.length, 10);
      expect(rejected, {PhotoRejection.tooMany});
    });

    test('a photo can be removed', () {
      final form = model();
      form.addPhotos([photo('a.jpg'), photo('b.jpg')]);
      form.removePhoto(0);

      expect(form.photos.single.name, 'b.jpg');
    });
  });

  group('sending', () {
    Future<AddProductViewModel> filled(_Products products) async {
      final form = AddProductViewModel(
        products: products,
        catalogue: FakeCatalogueRepository(),
      );
      addTearDown(form.dispose);
      form.name.controller.text = 'Sac cuir';
      form.sku.controller.text = 'SAC-01';
      form.costPrice.controller.text = '1000';
      form.sellingPrice.controller.text = '1500';
      form.quantity.controller.text = '3';
      return form;
    }

    test('photos are uploaded to the product that was just created', () async {
      final products = _Products();
      final form = await filled(products);
      form.addPhotos([photo('a.jpg'), photo('b.png')]);

      final created = await form.submitAndCreate();

      expect(created?.id, 'p-9');
      expect(products.uploads.single.productId, 'p-9');
      expect(products.uploads.single.names, ['a.jpg', 'b.png']);
      expect(form.photosFailed, isFalse);
    });

    test('a failed upload does not undo the product, and is reported',
        () async {
      final products = _Products(uploadFails: true);
      final form = await filled(products);
      form.addPhotos([photo('a.jpg')]);

      final created = await form.submitAndCreate();

      expect(created?.id, 'p-9');
      expect(form.photosFailed, isTrue);
    });

    test('no photos, no upload', () async {
      final products = _Products();
      final form = await filled(products);

      await form.submitAndCreate();

      expect(products.uploads, isEmpty);
    });
  });
}

class _Products extends ProductRepository {
  _Products({this.uploadFails = false}) : super(api: apiForTest());

  final bool uploadFails;
  final uploads = <({String productId, List<String> names})>[];

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
  }) async =>
      Result.success(Product.fromJson({'id': 'p-9', 'sku': sku, 'name': name}));

  @override
  Future<Result<int>> uploadImages({
    required String productId,
    required List<ProductPhoto> photos,
  }) async {
    uploads.add((
      productId: productId,
      names: photos.map((p) => p.name).toList(),
    ));
    return uploadFails
        ? const Result.failure(ServerException('upload failed'))
        : Result.success(photos.length);
  }
}

/// Answers every request from a callback instead of the network.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

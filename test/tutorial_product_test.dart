import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/network/api_client.dart';
import 'package:djaber_mobile/core/storage/secure_storage.dart';
import 'package:djaber_mobile/core/utils/validators.dart';
import 'package:djaber_mobile/data/models/product.dart';

import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// `T3 — Produit`: the validation rules the backend actually enforces, and the
/// create call itself.
///
/// The request is real — a stubbed `Dio` adapter answers it — so the body the
/// app sends and the response it parses are both asserted, rather than a mock
/// repository standing in for both.
void main() {
  late List<RequestOptions> sent;
  late ProductRepository repo;

  /// Answers the next request with [status] and [body].
  void stub(int status, Map<String, dynamic> body) {
    final dio = Dio();
    sent = [];
    dio.httpClientAdapter = _StubAdapter((options) {
      sent.add(options);
      return ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-token'});
    repo = ProductRepository(
      api: ApiClient(
        storage: SecureStorage(),
        onUnauthorized: () async {},
        dio: dio,
      ),
    );
  }

  group('the rules the backend enforces', () {
    test('a price must be present, numeric and greater than zero', () {
      expect(Validators.price(''), FieldError.required);
      expect(Validators.price('abc'), FieldError.notANumber);
      // The controller rejects 0 outright: "Cost price is required and must be
      // greater than 0". "Required" would be the wrong message for a field
      // that visibly contains a zero.
      expect(Validators.price('0'), FieldError.mustBePositive);
      expect(Validators.price('-5'), FieldError.mustBePositive);
      expect(Validators.price('1200'), isNull);
      expect(Validators.price('1200.50'), isNull);
    });

    test('a comma is a decimal separator, and spaces are ignored', () {
      // French convention, and what an Algerian handset's keyboard offers.
      expect(Validators.parseAmount('1200,50'), 1200.5);
      expect(Validators.parseAmount('1 200,50'), 1200.5);
      expect(Validators.price('1200,50'), isNull);
    });

    test('the selling price may not sit below the cost price', () {
      final selling = Validators.sellingPrice(() => '1000');
      expect(selling('900'), FieldError.belowCostPrice);
      expect(selling('1000'), isNull); // >= is allowed, not >
      expect(selling('1500'), isNull);
    });

    test('it stays quiet while the cost price is itself unreadable', () {
      // Otherwise the form blames the selling price for the cost field's
      // problem.
      final selling = Validators.sellingPrice(() => '');
      expect(selling('900'), isNull);
      expect(Validators.sellingPrice(() => 'abc')('900'), isNull);
    });

    test('the initial quantity is a whole number above zero', () {
      expect(Validators.quantity(''), FieldError.required);
      expect(Validators.quantity('2.5'), FieldError.notANumber);
      expect(Validators.quantity('0'), FieldError.mustBePositive);
      expect(Validators.quantity('12'), isNull);
    });
  });

  group('create', () {
    test('sends the fields the controller reads, and parses the product',
        () async {
      stub(201, {
        'product': {
          'id': 'p-1',
          'sku': 'PRD-001',
          'name': 'Robe satin — Noir',
          'description': 'Satin, noir, taille M',
          // Prisma Decimal arrives as a string; Int as a number.
          'costPrice': '1200.00',
          'sellingPrice': '2400.00',
          'quantity': 12,
          'minQuantity': 0,
          'unit': 'piece',
          'isActive': true,
        },
      });

      final result = await repo.create(
        sku: '  PRD-001 ',
        name: '  Robe satin — Noir ',
        description: 'Satin, noir, taille M',
        costPrice: 1200,
        sellingPrice: 2400,
        quantity: 12,
      );

      expect(result.isSuccess, isTrue);
      final product = result.valueOrNull!;
      expect(product.id, 'p-1');
      // The decimal came through as a string and must not have thrown.
      expect(product.costPrice, 1200.0);
      expect(product.sellingPrice, 2400.0);
      expect(product.quantity, 12);
      expect(product.margin, 1200.0);

      final body = sent.single.data as Map<String, dynamic>;
      expect(sent.single.path, '/api/user-stock/products');
      // Trimmed, because the controller compares against the trimmed value.
      expect(body['sku'], 'PRD-001');
      expect(body['name'], 'Robe satin — Noir');
      expect(body['costPrice'], 1200);
      expect(body['quantity'], 12);
      expect(body['minQuantity'], 0);
      // Not sent at all when the merchant left them alone.
      expect(body.containsKey('categoryId'), isFalse);
      expect(body.containsKey('unitId'), isFalse);
    });

    test('an empty description is omitted rather than sent blank', () async {
      stub(201, {
        'product': {'id': 'p-2', 'sku': 'S', 'name': 'N'},
      });

      await repo.create(
        sku: 'S',
        name: 'N',
        description: '   ',
        costPrice: 1,
        sellingPrice: 2,
        quantity: 1,
      );

      // The column is nullable and the controller would store "".
      final body = sent.single.data as Map<String, dynamic>;
      expect(body.containsKey('description'), isFalse);
    });

    test('a duplicate SKU comes back as a 400 carrying the reason', () async {
      // Not a 409 — `@@unique([userId, sku])` surfaces as Prisma P2002 and the
      // controller answers 400 { error: 'SKU already exists' }.
      stub(400, {'error': 'SKU already exists'});

      final result = await repo.create(
        sku: 'PRD-001',
        name: 'N',
        costPrice: 1,
        sellingPrice: 2,
        quantity: 1,
      );

      expect(result.isFailure, isTrue);
      final error = result.errorOrNull!;
      expect(error, isA<ValidationException>());
      // The server's own sentence survives, so the screen can show it.
      expect(error.message, 'SKU already exists');
    });

    test('a bare product object parses too', () async {
      stub(201, {'id': 'p-3', 'sku': 'S', 'name': 'N', 'quantity': 4});

      final result = await repo.create(
        sku: 'S',
        name: 'N',
        costPrice: 1,
        sellingPrice: 2,
        quantity: 4,
      );

      expect(result.valueOrNull?.quantity, 4);
    });
  });

  group('Product', () {
    test('reads decimals from strings and flags low stock', () {
      final product = Product.fromJson({
        'id': 'p',
        'sku': 'S',
        'name': 'N',
        'costPrice': '10.50',
        'sellingPrice': '25.00',
        'quantity': 3,
        'minQuantity': 5,
      });

      expect(product.costPrice, 10.5);
      expect(product.margin, 14.5);
      expect(product.isLowStock, isTrue);
      expect(product.isOutOfStock, isFalse);
    });

    test('no threshold means nothing is low', () {
      final product = Product.fromJson({
        'id': 'p',
        'sku': 'S',
        'name': 'N',
        'quantity': 1,
        'minQuantity': 0,
      });
      expect(product.isLowStock, isFalse);
    });
  });
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

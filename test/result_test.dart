import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every repository call returns a `Result`, so the two branches and the
/// helpers on top of them are load-bearing for the whole data layer.
void main() {
  group('Success', () {
    const result = Result<int>.success(7);

    test('reports success and carries the value', () {
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 7);
      expect(result.errorOrNull, isNull);
    });

    test('map transforms the value', () {
      expect(result.map((v) => v * 2).valueOrNull, 14);
    });

    test('fold takes the success branch', () {
      final taken = result.fold(
        onSuccess: (v) => 'ok $v',
        onFailure: (e) => 'err',
      );
      expect(taken, 'ok 7');
    });
  });

  group('Failure', () {
    const error = NetworkException();
    const result = Result<int>.failure(error);

    test('reports failure and carries the error', () {
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, error);
    });

    test('map passes the error through without calling the transform', () {
      var called = false;
      final mapped = result.map((v) {
        called = true;
        return v * 2;
      });
      expect(called, isFalse);
      expect(mapped.errorOrNull, error);
    });

    test('fold takes the failure branch', () {
      final taken = result.fold(
        onSuccess: (v) => 'ok',
        onFailure: (e) => 'err ${e.message}',
      );
      expect(taken, 'err No connection');
    });
  });

  test('exhaustive switch — the reason Result is sealed', () {
    String describe(Result<int> r) => switch (r) {
          Success(:final value) => 'value $value',
          Failure(:final error) => 'error ${error.message}',
        };

    expect(describe(const Result.success(1)), 'value 1');
    expect(
      describe(const Result.failure(NotFoundException())),
      'error Not found',
    );
  });
}

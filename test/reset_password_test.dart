import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/core/utils/validators.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/auth_repository.dart';
import 'package:djaber_mobile/presentation/viewmodels/reset_password_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// `08b — Nouveau mot de passe`, opened by the e-mail's link (brief §25.19).
void main() {
  const token = '3f9a1c0e7b2d4a6f8e1c3b5d7a9f0e2c4b6d8a0f1e3c5b7d9a2f4e6c8b0d1a3f';

  test('only a 64-hex token counts', () {
    expect(ResetPasswordViewModel.tokenFrom(token), token);
    expect(ResetPasswordViewModel.tokenFrom(' ${token.toUpperCase()} '), token);
    expect(ResetPasswordViewModel.tokenFrom(token.substring(1)), isNull);
    expect(ResetPasswordViewModel.tokenFrom('abc'), isNull);
  });

  test('a malformed token is a dead link, never sent', () async {
    final auth = _FakeAuth(verify: const Result.success(true));
    final model = ResetPasswordViewModel(auth: auth, token: 'abc');
    addTearDown(model.dispose);

    expect(model.phase, ResetPhase.linkDead);
    await model.verify();
    expect(auth.verified, isEmpty);
  });

  test('the link is checked before the password is asked', () async {
    final auth = _FakeAuth(verify: const Result.success(true));
    final model = ResetPasswordViewModel(auth: auth, token: token);
    addTearDown(model.dispose);

    expect(model.phase, ResetPhase.checking);
    await model.verify();
    expect(auth.verified, [token]);
    expect(model.phase, ResetPhase.ready);
  });

  test('expired: only a new link helps', () async {
    const expired = ValidationException(
      'This reset link has expired. Request a new one.',
      statusCode: 400,
      code: 'AUTH_RESET_TOKEN_EXPIRED',
    );
    final model = ResetPasswordViewModel(auth: _FakeAuth(verify: const Result.failure(expired)), token: token);
    addTearDown(model.dispose);

    await model.verify();
    expect(model.phase, ResetPhase.linkDead);
    expect(model.error?.code, 'AUTH_RESET_TOKEN_EXPIRED');
  });

  test('offline: retry, not "request a new link"', () async {
    final model = ResetPasswordViewModel(
      auth: _FakeAuth(verify: const Result.failure(NetworkException())),
      token: token,
    );
    addTearDown(model.dispose);

    await model.verify();
    expect(model.phase, ResetPhase.unreachable);
  });

  test('a password under 8 characters never reaches the server', () async {
    final auth = _FakeAuth(verify: const Result.success(true));
    final model = ResetPasswordViewModel(auth: auth, token: token);
    addTearDown(model.dispose);
    await model.verify();

    model.password.controller.text = 'court';
    model.confirm.controller.text = 'court';
    expect(model.canSubmit, isFalse);
    expect(await model.save(), isNull);
    expect(auth.resetCalls, isEmpty);
  });

  test('the password must be typed twice, identically', () async {
    final auth = _FakeAuth(verify: const Result.success(true));
    final model = ResetPasswordViewModel(auth: auth, token: token);
    addTearDown(model.dispose);
    await model.verify();

    model.password.controller.text = 'N3wS3cretPass';
    expect(model.canSubmit, isFalse, reason: 'no confirmation yet');
    expect(model.confirm.error, FieldError.required);

    model.confirm.controller.text = 'N3wS3cretPas';
    expect(model.confirm.error, FieldError.mismatch);
    expect(model.canSubmit, isFalse);
    expect(await model.save(), isNull);
    expect(auth.resetCalls, isEmpty, reason: 'a mismatch never reaches the server');

    model.confirm.controller.text = 'N3wS3cretPass';
    expect(model.canSubmit, isTrue);

    // Changing the first entry afterwards breaks the match again.
    model.password.controller.text = 'N3wS3cretPass!';
    expect(model.canSubmit, isFalse);
  });

  test('saved: the user comes back for the session', () async {
    const user = User(id: 'u1', email: 'amina@shop.dz', firstName: 'Amina', lastName: 'B.');
    final auth = _FakeAuth(verify: const Result.success(true), reset: const Result.success(user));
    final model = ResetPasswordViewModel(auth: auth, token: token);
    addTearDown(model.dispose);
    await model.verify();

    model.password.controller.text = 'N3wS3cretPass';
    model.confirm.controller.text = 'N3wS3cretPass';
    expect(await model.save(), user);
    expect(auth.resetCalls, [(token, 'N3wS3cretPass')]);
  });

  test('the link dying while typing sends the merchant for a new one', () async {
    const used = ValidationException(
      'This reset link is invalid or has already been used. Request a new one.',
      statusCode: 400,
      code: 'AUTH_RESET_TOKEN_INVALID',
    );
    final model = ResetPasswordViewModel(
      auth: _FakeAuth(verify: const Result.success(true), reset: const Result.failure(used)),
      token: token,
    );
    addTearDown(model.dispose);
    await model.verify();

    model.password.controller.text = 'N3wS3cretPass';
    model.confirm.controller.text = 'N3wS3cretPass';
    expect(await model.save(), isNull);
    expect(model.phase, ResetPhase.linkDead);
  });

  test('a refused password stays on the form, under the field', () async {
    const weak = ValidationException(
      'Some fields are invalid. Please check the form.',
      statusCode: 400,
      code: 'VALIDATION_FAILED',
      fields: [ApiFieldError(field: 'password', code: 'FIELD_TOO_SHORT', message: 'Too short.')],
    );
    final model = ResetPasswordViewModel(
      auth: _FakeAuth(verify: const Result.success(true), reset: const Result.failure(weak)),
      token: token,
    );
    addTearDown(model.dispose);
    await model.verify();

    model.password.controller.text = 'N3wS3cretPass';
    model.confirm.controller.text = 'N3wS3cretPass';
    expect(await model.save(), isNull);
    expect(model.phase, ResetPhase.ready);
    expect(model.passwordServerError, 'Too short.');
  });
}

class _FakeAuth implements AuthRepository {
  _FakeAuth({required this.verify, this.reset});

  final Result<bool> verify;
  final Result<User>? reset;

  final verified = <String>[];
  final resetCalls = <(String, String)>[];

  @override
  Future<Result<bool>> verifyResetToken(String token) async {
    verified.add(token);
    return verify;
  }

  @override
  Future<Result<User>> resetPassword({required String token, required String password}) async {
    resetCalls.add((token, password));
    return reset!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/core/storage/secure_storage.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/auth_repository.dart';

import 'auth_host.dart';

/// An [AuthRepository] that succeeds without a network.
///
/// A subclass rather than an interface, for the same reason as the other
/// fakes: [SessionViewModel] holds the concrete type, and overriding the two
/// entry points leaves everything else — the token persistence, the profile
/// merge — exactly as the app has it.
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({required super.prefs, this.fails = false})
      : super(api: apiForTest(), secureStorage: SecureStorage());

  final bool fails;

  /// The merchant every successful call returns.
  static const merchant = User(
    id: 'u-1',
    email: 'amina@shop.dz',
    firstName: 'Amina',
    lastName: 'Benali',
  );

  int logins = 0;
  int registrations = 0;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    logins++;
    return fails
        ? const Result.failure(UnauthorizedException())
        : const Result.success(merchant);
  }

  @override
  Future<Result<User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    registrations++;
    return fails
        ? const Result.failure(ValidationException('taken'))
        : const Result.success(merchant);
  }

  /// Never called in these tests, and answering it would let a background
  /// refresh overwrite the record under an assertion.
  @override
  Future<Result<User>> fetchProfile() async =>
      const Result.failure(NetworkException());
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage for credentials.
///
/// The auth token lives here rather than in `SharedPreferences` — on Android it
/// goes through the Keystore, so it survives a backup extraction that would
/// hand over a plain prefs file.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              // v11 encrypts by default (AES-GCM through the Keystore).
              // `resetOnError` clears an entry the Keystore can no longer
              // decrypt instead of throwing forever — that state is real on
              // Android after some device restores, and the recovery a
              // merchant needs is a login screen, not a permanently broken app.
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _kAuthToken = 'auth_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';

  /// Cached in memory so the network layer does not hit the Keystore on every
  /// request — that call is slow enough to be visible on low-end Android.
  String? _cachedToken;
  bool _tokenLoaded = false;

  Future<String?> readAuthToken() async {
    if (_tokenLoaded) return _cachedToken;
    _cachedToken = await _read(_kAuthToken);
    _tokenLoaded = true;
    return _cachedToken;
  }

  Future<void> writeAuthToken(String token) async {
    _cachedToken = token;
    _tokenLoaded = true;
    await _storage.write(key: _kAuthToken, value: token);
  }

  Future<String?> readRefreshToken() => _read(_kRefreshToken);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  Future<String?> readUserId() => _read(_kUserId);

  Future<void> writeUserId(String id) => _storage.write(key: _kUserId, value: id);

  /// Wipes everything credential-shaped. Called on logout and on a hard 401.
  Future<void> clear() async {
    _cachedToken = null;
    _tokenLoaded = true;
    await _storage.deleteAll();
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      // A corrupted Keystore entry (seen after some Android restores) throws
      // rather than returning null. Treat it as "not logged in".
      return null;
    }
  }
}

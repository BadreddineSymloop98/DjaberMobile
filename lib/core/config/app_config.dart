/// Environment configuration.
///
/// Every value is overridable at build time with `--dart-define`, so a release
/// binary can be pointed at a different backend without a code change. This
/// matters: the brief flags the hardcoded IP-derived host as a ship blocker
/// (Q12) — a published mobile binary cannot be redeployed the way the web can.
///
///   flutter build apk --dart-define=API_BASE_URL=https://api.djaber.ai
library;

import 'package:flutter/foundation.dart';

enum Flavor { dev, staging, prod }

class AppConfig {
  const AppConfig._();

  /// Backend base URL. Defaults to the current sslip.io host used by the web
  /// app and the existing Flutter skeleton. Replace the default the moment a
  /// stable domain exists.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://djaber.72-60-190-211.sslip.io',
  );

  static const String _flavorName = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'prod',
  );

  static Flavor get flavor => switch (_flavorName) {
        'dev' => Flavor.dev,
        'staging' => Flavor.staging,
        _ => Flavor.prod,
      };

  static bool get isProd => flavor == Flavor.prod;

  /// Network timeouts. Deliberately generous — the target market is Algerian
  /// mobile data on low-end Android, not office wifi.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// How many times an idempotent request is retried on a transport failure.
  static const int maxRetries = 2;
  static const Duration retryBackoff = Duration(milliseconds: 800);

  /// The app polls rather than holding a socket open (v1 decision, brief §10).
  static const Duration inboxPollInterval = Duration(seconds: 20);
  static const Duration conversationPollInterval = Duration(seconds: 8);

  /// Verbose request/response logging. Never on in a release build.
  static const bool enableNetworkLogs = kDebugMode;
}

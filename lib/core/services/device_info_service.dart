import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Device and build facts, read once at startup.
///
/// Two uses. First, `POST /api/devices/register` wants a platform alongside the
/// push token. Second, and specific to this market: brief §9 records that
/// Xiaomi, Oppo, Vivo, Huawei, Infinix and Tecno aggressively kill background
/// apps and delay notifications, which is a direct threat to the one thing the
/// app promises. Knowing the manufacturer lets the app show the right
/// autostart / battery-optimisation guidance instead of generic advice, and
/// lets delivery problems be attributed to a make rather than guessed at.
class DeviceInfoService {
  DeviceInfoService._(this.platform, this.manufacturer, this.model,
      this.osVersion, this.appVersion, this.buildNumber);

  final String platform;
  final String manufacturer;
  final String model;
  final String osVersion;
  final String appVersion;
  final String buildNumber;

  /// Manufacturers known to need explicit autostart permission before push is
  /// reliable. Lowercase, compared with `contains`.
  static const _aggressiveOems = {
    'xiaomi',
    'redmi',
    'poco',
    'oppo',
    'realme',
    'oneplus',
    'vivo',
    'iqoo',
    'huawei',
    'honor',
    'infinix',
    'tecno',
    'itel',
    'meizu',
    'asus',
    'samsung',
  };

  /// True when this handset needs the merchant to allow autostart or exempt
  /// the app from battery optimisation for notifications to arrive on time.
  bool get needsAutostartGuidance =>
      Platform.isAndroid &&
      _aggressiveOems.any(manufacturer.toLowerCase().contains);

  String get versionLabel => '$appVersion ($buildNumber)';

  static Future<DeviceInfoService> load() async {
    final package = await PackageInfo.fromPlatform();
    final plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await plugin.androidInfo;
      return DeviceInfoService._(
        'android',
        android.manufacturer,
        android.model,
        'Android ${android.version.release} (SDK ${android.version.sdkInt})',
        package.version,
        package.buildNumber,
      );
    }
    if (Platform.isIOS) {
      final ios = await plugin.iosInfo;
      return DeviceInfoService._(
        'ios',
        'Apple',
        ios.utsname.machine,
        '${ios.systemName} ${ios.systemVersion}',
        package.version,
        package.buildNumber,
      );
    }
    return DeviceInfoService._(
      Platform.operatingSystem,
      'unknown',
      'unknown',
      Platform.operatingSystemVersion,
      package.version,
      package.buildNumber,
    );
  }
}

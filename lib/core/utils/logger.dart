import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal tagged logger. No dependency, no output in release.
///
/// Deliberately not a package: the app needs tagged lines in `flutter run` and
/// nothing more, and every logging package on pub costs APK size for features
/// this project will not use.
class Log {
  const Log._();

  static const String _name = 'djaber';

  static void d(Object? message, {String? tag}) =>
      _write(message, tag: tag, level: 500);

  static void i(Object? message, {String? tag}) =>
      _write(message, tag: tag, level: 800);

  static void w(Object? message, {String? tag}) =>
      _write(message, tag: tag, level: 900);

  static void e(
    Object? message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _write(
        message,
        tag: tag,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );

  static void _write(
    Object? message, {
    String? tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    developer.log(
      message.toString(),
      name: tag == null ? _name : '$_name.$tag',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

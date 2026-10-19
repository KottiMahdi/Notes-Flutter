import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Developer-only logging. Nothing logged here is shown to users.
/// Swap the body of [error] to forward to Crashlytics/Sentry in release.
class AppLogger {
  const AppLogger._();

  static void info(String message, {String name = 'app'}) {
    if (kDebugMode) developer.log(message, name: name);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'app',
  }) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

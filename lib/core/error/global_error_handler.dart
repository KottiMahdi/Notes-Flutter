import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// Installs framework + platform error hooks and runs [body] in a guarded zone.
void runGuarded(FutureOr<void> Function() body) {
  runZonedGuarded(() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'FlutterError: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
        name: 'flutter',
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Uncaught platform error',
          error: error, stackTrace: stack, name: 'platform');
      return true;
    };

    await body();
  }, (error, stack) {
    AppLogger.error('Uncaught zone error',
        error: error, stackTrace: stack, name: 'zone');
  });
}

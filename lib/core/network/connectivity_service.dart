import 'package:connectivity_plus/connectivity_plus.dart';

import '../error/app_logger.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Shared instance; override in tests with a fake.
  static ConnectivityService instance = ConnectivityService();

  /// True when a network interface is up. Fails open (returns true) if the
  /// platform check itself fails, so a broken plugin never blocks the app.
  Future<bool> get isOnline async {
    try {
      final results = await _connectivity
          .checkConnectivity()
          .timeout(const Duration(seconds: 2));
      return !results.every((r) => r == ConnectivityResult.none);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Connectivity check failed; allowing request to proceed.',
        error: error,
        stackTrace: stackTrace,
        name: 'connectivity',
      );
      return true;
    }
  }

  Stream<bool> get onStatusChanged => _connectivity.onConnectivityChanged
      .map((results) => !results.every((r) => r == ConnectivityResult.none));
}

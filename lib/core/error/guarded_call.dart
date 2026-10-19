import 'dart:async';

import '../network/connectivity_service.dart';
import 'error_mapper.dart';
import 'failures.dart';

/// Runs a data-layer [action], enforcing a timeout and mapping every error
/// to a [Failure].
///
/// Set [isWrite] for mutations: Firestore queues offline writes and never
/// completes them, so we fail fast with [NetworkFailure] instead of hanging.
Future<T> guardedCall<T>(
  Future<T> Function() action, {
  bool isWrite = false,
  Duration timeout = const Duration(seconds: 15),
}) async {
  try {
    if (isWrite && !await ConnectivityService.instance.isOnline) {
      throw const NetworkFailure();
    }
    return await action().timeout(timeout);
  } on Failure {
    rethrow;
  } catch (error, stackTrace) {
    throw mapToFailure(error, stackTrace);
  }
}

/// Typed errors for the data layer. [message] is always safe to show to users;
/// [cause] and [stackTrace] are for developer logs only.
sealed class Failure implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.cause, this.stackTrace});

  /// Whether retrying the same operation may succeed.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message =
        'No internet connection. Check your network and try again.',
    super.cause,
    super.stackTrace,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'The request took too long. Please try again.',
    super.cause,
    super.stackTrace,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

class ServerFailure extends Failure {
  final String? code;

  const ServerFailure({
    String message = 'The service is having problems. Please try again later.',
    this.code,
    super.cause,
    super.stackTrace,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'You do not have permission to do that.',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

class AuthenticationFailure extends Failure {
  final String code;

  const AuthenticationFailure({
    required this.code,
    required String message,
    super.cause,
    super.stackTrace,
  }) : super(message);

  @override
  bool get isRetryable =>
      code == 'network-request-failed' ||
      code == 'too-many-requests' ||
      code == 'internal-error';
}

class AuthActionCancelledException extends Failure {
  const AuthActionCancelledException([
    super.message = 'Google sign-in was cancelled.',
  ]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'The item was not found.',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Could not read or save data on this device.',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

class DataFailure extends Failure {
  const DataFailure({
    String message = 'Some data could not be read. Please try again.',
    super.cause,
    super.stackTrace,
  }) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Something went wrong. Please try again.',
    super.cause,
    super.stackTrace,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

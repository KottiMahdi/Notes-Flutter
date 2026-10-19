import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'app_logger.dart';
import 'failures.dart';

/// Converts any thrown object into a typed [Failure] and logs the original.
Failure mapToFailure(Object error, [StackTrace? stackTrace]) {
  if (error is Failure) return error;

  final Failure failure;
  if (error is TimeoutException) {
    failure = TimeoutFailure(cause: error, stackTrace: stackTrace);
  } else if (error is SocketException) {
    failure = NetworkFailure(cause: error, stackTrace: stackTrace);
  } else if (error is FirebaseAuthException) {
    failure = _fromAuth(error, stackTrace);
  } else if (error is FirebaseException) {
    failure = _fromFirebase(error, stackTrace);
  } else if (error is FormatException || error is TypeError) {
    failure = DataFailure(cause: error, stackTrace: stackTrace);
  } else if (error is FileSystemException) {
    failure = CacheFailure(cause: error, stackTrace: stackTrace);
  } else {
    failure = UnknownFailure(cause: error, stackTrace: stackTrace);
  }

  AppLogger.error(
    'Mapped ${error.runtimeType} -> ${failure.runtimeType}',
    error: error,
    stackTrace: stackTrace,
    name: 'error_mapper',
  );
  return failure;
}

Failure _fromAuth(FirebaseAuthException e, StackTrace? st) {
  switch (e.code) {
    case 'network-request-failed':
      return NetworkFailure(cause: e, stackTrace: st);
    case 'too-many-requests':
      return AuthenticationFailure(
        code: e.code,
        message: 'Too many attempts. Please wait and try again.',
        cause: e,
        stackTrace: st,
      );
    case 'invalid-email':
      return AuthenticationFailure(
        code: e.code,
        message: 'Enter a valid email address.',
        cause: e,
        stackTrace: st,
      );
    case 'user-disabled':
      return AuthenticationFailure(
        code: e.code,
        message: 'This account has been disabled.',
        cause: e,
        stackTrace: st,
      );
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return AuthenticationFailure(
        code: e.code,
        message: 'The email or password is incorrect.',
        cause: e,
        stackTrace: st,
      );
    case 'email-already-in-use':
      return AuthenticationFailure(
        code: e.code,
        message: 'An account already exists for this email.',
        cause: e,
        stackTrace: st,
      );
    case 'weak-password':
      return AuthenticationFailure(
        code: e.code,
        message: 'Choose a stronger password.',
        cause: e,
        stackTrace: st,
      );
    case 'operation-not-allowed':
      return AuthenticationFailure(
        code: e.code,
        message: 'This sign-in method is not enabled.',
        cause: e,
        stackTrace: st,
      );
    case 'email-not-verified':
      return AuthenticationFailure(
        code: e.code,
        message: 'Please verify your email before continuing.',
        cause: e,
        stackTrace: st,
      );
    case 'no-current-user':
      return AuthenticationFailure(
        code: e.code,
        message: 'Please sign in again to continue.',
        cause: e,
        stackTrace: st,
      );
    case 'requires-recent-login':
      return AuthenticationFailure(
        code: e.code,
        message: 'Please sign in again before making this change.',
        cause: e,
        stackTrace: st,
      );
    case 'user-null':
      return AuthenticationFailure(
        code: e.code,
        message: 'Sign-in did not complete. Please try again.',
        cause: e,
        stackTrace: st,
      );
    default:
      return AuthenticationFailure(
        code: e.code,
        message: 'Sign-in failed. Please try again.',
        cause: e,
        stackTrace: st,
      );
  }
}

Failure _fromFirebase(FirebaseException e, StackTrace? st) {
  switch (e.code) {
    case 'unavailable':
    case 'network-request-failed':
      return NetworkFailure(cause: e, stackTrace: st);
    case 'deadline-exceeded':
      return TimeoutFailure(cause: e, stackTrace: st);
    case 'permission-denied':
    case 'unauthenticated':
      return PermissionFailure(cause: e, stackTrace: st);
    case 'not-found':
      return NotFoundFailure(cause: e, stackTrace: st);
    case 'resource-exhausted':
    case 'internal':
    case 'aborted':
    case 'data-loss':
    case 'unimplemented':
      return ServerFailure(code: e.code, cause: e, stackTrace: st);
    default:
      return UnknownFailure(cause: e, stackTrace: st);
  }
}

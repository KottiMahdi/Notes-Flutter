import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../error/error_mapper.dart';
import '../error/failures.dart';

class AppErrorMessages {
  const AppErrorMessages._();

  static String fromException(
    Object? error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is AuthActionCancelledException) {
      return error.message;
    }

    if (error is UnknownFailure) {
      return fallback;
    }

    if (error is Failure) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      final failure = mapToFailure(error);
      return failure is UnknownFailure ? fallback : failure.message;
    }

    if (error is FirebaseException) {
      return _firebaseMessage(error.code, fallback);
    }

    if (error is TimeoutException) {
      return 'The request took too long. Please try again.';
    }

    if (error is SocketException) {
      return 'Check your internet connection and try again.';
    }

    if (error is ArgumentError) {
      final message = error.message;
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }

  static String _firebaseMessage(String code, String fallback) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to do that.';
      case 'unauthenticated':
        return 'Please sign in again to continue.';
      case 'not-found':
        return 'The item was not found.';
      case 'already-exists':
        return 'That item already exists.';
      case 'unavailable':
        return 'The service is temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'The request took too long. Please try again.';
      case 'cancelled':
        return 'The operation was cancelled.';
      default:
        return fallback;
    }
  }
}

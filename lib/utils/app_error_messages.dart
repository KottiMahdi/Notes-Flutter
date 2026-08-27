import 'package:firebase_auth/firebase_auth.dart';

class AuthActionCancelledException implements Exception {
  final String message;

  const AuthActionCancelledException([
    this.message = 'Google sign-in was cancelled.',
  ]);

  @override
  String toString() => message;
}

class AppErrorMessages {
  const AppErrorMessages._();

  static String fromException(
    Object? error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is AuthActionCancelledException) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      return _authMessage(error.code, fallback);
    }

    if (error is FirebaseException) {
      return _firebaseMessage(error.code, fallback);
    }

    if (error is ArgumentError) {
      final message = error.message;
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }

  static String _authMessage(String code, String fallback) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'email-not-verified':
        return 'Please verify your email before continuing.';
      case 'no-current-user':
        return 'Please sign in again to continue.';
      case 'user-null':
        return 'Sign-in did not complete. Please try again.';
      case 'requires-recent-login':
        return 'Please sign in again before making this change.';
      case 'google-sign-out-failed':
        return 'Signed out locally, but Google sign-out did not finish.';
      default:
        return fallback;
    }
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

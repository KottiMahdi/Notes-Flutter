import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/core/error/error_mapper.dart';
import 'package:notes_management_mobile_application/core/error/failures.dart';

void main() {
  group('mapToFailure', () {
    test('maps Firebase Auth network errors without exposing SDK text', () {
      final failure = mapToFailure(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'internal socket details',
        ),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, isNot(contains('internal socket details')));
    });

    test('maps credential errors to a safe authentication failure', () {
      final failure = mapToFailure(
        FirebaseAuthException(code: 'wrong-password'),
      );

      expect(failure, isA<AuthenticationFailure>());
      expect(failure.message, 'The email or password is incorrect.');
    });

    test('maps Firestore deadline errors to timeout failures', () {
      final failure = mapToFailure(
        FirebaseException(plugin: 'cloud_firestore', code: 'deadline-exceeded'),
      );

      expect(failure, isA<TimeoutFailure>());
      expect(failure.isRetryable, isTrue);
    });
  });
}

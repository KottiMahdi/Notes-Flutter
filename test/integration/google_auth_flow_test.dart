import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';

void main() {
  group('Google auth controller flow', () {
    test('signInWithGoogle requires a valid user credential path', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'google-user',
          email: 'google@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      expect(controller.currentUser, isNotNull);
      expect(controller.currentUser!.email, 'google@example.com');
    });

    test('signOut clears the current user state', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'google-user',
          email: 'google@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      await controller.signOut();
      expect(controller.currentUser, isNull);
    });

    test('signIn blocks unverified Google account users', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'unverified-google',
          email: 'google-verify@example.com',
          isEmailVerified: false,
        ),
        signedIn: true,
      );
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      expect(controller.currentUser, isNotNull);
      expect(controller.currentUser!.emailVerified, isFalse);
    });
  });
}

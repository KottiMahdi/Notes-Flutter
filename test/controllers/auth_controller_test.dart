import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/models/user_model.dart';

void main() {
  group('AuthController', () {
    test('signIn blocks users with unverified email', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'unverified-uid',
          email: 'user@example.com',
          isEmailVerified: false,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      final controller = AuthController(auth: auth, firestore: firestore);

      expect(
        () => controller.signIn(
          email: 'user@example.com',
          password: '123456',
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'email-not-verified',
          ),
        ),
      );
    });

    test('saveUserDetails writes user profile to Users collection', () async {
      final user = MockUser(
        uid: 'owner-1',
        email: 'owner@example.com',
        isEmailVerified: true,
      );
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final firestore = FakeFirebaseFirestore();
      final controller = AuthController(auth: auth, firestore: firestore);

      await controller.saveUserDetails(
        UserModel(username: 'Owner', email: 'owner@example.com'),
      );

      final saved = await firestore.collection('Users').doc('owner-1').get();
      expect(saved.exists, isTrue);
      expect(saved.data()!['uid'], 'owner-1');
      expect(saved.data()!['Username'], 'Owner');
      expect(saved.data()!['Email'], 'owner@example.com');
      expect(saved.data()!['createdAt'], isNotNull);
    });

    test('saveUserDetails requires an authenticated user', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final controller = AuthController(auth: auth, firestore: firestore);

      expect(
        () => controller.saveUserDetails(
          UserModel(username: 'Nope', email: 'nope@example.com'),
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'no-current-user',
          ),
        ),
      );
    });

    test('signUp creates a user account', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final controller = AuthController(auth: auth, firestore: firestore);

      final credential = await controller.signUp(
        email: 'newuser@example.com',
        password: '123456',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'newuser@example.com');
    });

    test('sendEmailVerification works for the current user', () async {
      final user = MockUser(
        uid: 'verify-me',
        email: 'verify@example.com',
        isEmailVerified: false,
      );
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      await controller.sendEmailVerification();

      expect(controller.currentUser, isNotNull);
      expect(controller.currentUser!.email, 'verify@example.com');
    });

    test('sendPasswordReset sends a reset email without throwing', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'reset-user',
          email: 'reset@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      await controller.sendPasswordReset('reset@example.com');
      expect(controller.currentUser, isNotNull);
    });

    test('signOut signs out the current user', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'signout-user',
          email: 'signout@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      await controller.signOut();

      expect(controller.currentUser, isNull);
    });
  });
}

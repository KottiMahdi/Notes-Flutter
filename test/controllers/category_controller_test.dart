import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/category_controller.dart';

void main() {
  group('CategoryController', () {
    test('getCategories returns only the current user categories', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('categories').doc('cat-1').set({
        'name': 'Owner category',
        'userId': 'owner-user',
      });
      await firestore.collection('categories').doc('cat-2').set({
        'name': 'Other category',
        'userId': 'other-user',
      });

      final controller = CategoryController(firestore: firestore, auth: auth);
      final categories = await controller.getCategories();

      expect(categories.length, 1);
      expect(categories.first.name, 'Owner category');
      expect(categories.first.userId, 'owner-user');
    });

    test('addCategory creates category for the current user', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      final controller = CategoryController(firestore: firestore, auth: auth);

      await controller.addCategory('Work');

      final snapshot = await firestore.collection('categories').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Work');
      expect(snapshot.docs.first.data()['userId'], 'owner-user');
    });

    test('addCategory rejects empty names', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final controller = CategoryController(
        firestore: FakeFirebaseFirestore(),
        auth: auth,
      );

      expect(
        () => controller.addCategory('  '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateCategory updates an owned category', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      final categoryId = await _createCategory(
        firestore: firestore,
        userId: 'owner-user',
        name: 'Old title',
      );

      final controller = CategoryController(firestore: firestore, auth: auth);
      await controller.updateCategory(categoryId, 'New title');

      final updated =
          await firestore.collection('categories').doc(categoryId).get();
      expect(updated.data()!['name'], 'New title');
      expect(updated.data()!['userId'], 'owner-user');
    });

    test('deleteCategory rejects unauthorized access', () async {
      final ownerAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final intruderAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'intruder-user',
          email: 'intruder@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      final categoryId = await _createCategory(
        firestore: firestore,
        userId: 'owner-user',
        name: 'Private category',
      );

      final controller =
          CategoryController(firestore: firestore, auth: intruderAuth);

      expect(
        () => controller.updateCategory(categoryId, 'Hacked'),
        throwsA(isA<FirebaseException>()),
      );
      expect(
        () => controller.deleteCategory(categoryId),
        throwsA(isA<FirebaseException>()),
      );
      expect(ownerAuth.currentUser, isNotNull);
    });

    test('getCategories throws when no user is signed in', () async {
      final controller = CategoryController(
        firestore: FakeFirebaseFirestore(),
        auth: MockFirebaseAuth(),
      );

      expect(
        () => controller.getCategories(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}

Future<String> _createCategory({
  required FakeFirebaseFirestore firestore,
  required String userId,
  required String name,
}) async {
  final ref = await firestore.collection('categories').add({
    'name': name,
    'userId': userId,
  });
  return ref.id;
}

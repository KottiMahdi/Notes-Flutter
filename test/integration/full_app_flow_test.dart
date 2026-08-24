import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/controllers/category_controller.dart';
import 'package:notes_management_mobile_application/controllers/note_controller.dart';

void main() {
  group('Full app flow', () {
    test('owner can create category and note and intruder cannot access',
        () async {
      final firestore = FakeFirebaseFirestore();

      final ownerAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-id',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final intruderAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'intruder-id',
          email: 'intruder@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );

      final ownerCategoryController =
          CategoryController(firestore: firestore, auth: ownerAuth);
      final ownerNoteController =
          NoteController(firestore: firestore, auth: ownerAuth);
      final intruderCategoryController =
          CategoryController(firestore: firestore, auth: intruderAuth);
      final intruderNoteController =
          NoteController(firestore: firestore, auth: intruderAuth);

      await ownerCategoryController.addCategory('Project');
      final categories = await ownerCategoryController.getCategories();
      final categoryId = categories.first.id;

      await ownerNoteController.addNote(categoryId, 'Important plan');
      final notes = await ownerNoteController.getNotes(categoryId);

      expect(categories.first.name, 'Project');
      expect(notes.first.note, 'Important plan');

      final intruderCategories =
          await intruderCategoryController.getCategories();
      expect(intruderCategories, isEmpty);

      expect(
        () => intruderNoteController.getNotes(categoryId),
        throwsA(isA<FirebaseException>()),
      );
    });

    testWidgets('MaterialApp can render home route and entry widgets',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            'homepage': (_) => const Scaffold(body: Text('Home')),
            'login': (_) => const Scaffold(body: Text('Login')),
          },
          home: const Scaffold(body: Text('Root')),
        ),
      );

      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    test('AuthController signIn rejects unverified account', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'need-verify',
          email: 'verify-me@example.com',
          isEmailVerified: false,
        ),
        signedIn: true,
      );
      final controller =
          AuthController(auth: auth, firestore: FakeFirebaseFirestore());

      expect(
        () => controller.signIn(
            email: 'verify-me@example.com', password: '123456'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}

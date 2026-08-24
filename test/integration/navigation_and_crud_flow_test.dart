import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/controllers/category_controller.dart';
import 'package:notes_management_mobile_application/controllers/note_controller.dart';
import 'package:notes_management_mobile_application/views/home/home_view.dart';
import 'package:notes_management_mobile_application/views/notes/note_list_view.dart';

void main() {
  group('Navigation and CRUD flow', () {
    testWidgets('home view can be created and shows categories screen shell',
        (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            'login': (_) => const Scaffold(body: Text('Login')),
            'homepage': (_) => const Scaffold(body: Text('Home')),
          },
          home: HomeView(
            categoryController:
                CategoryController(firestore: firestore, auth: auth),
            authController: AuthController(auth: auth, firestore: firestore),
          ),
        ),
      );

      expect(find.text('List of categories'), findsOneWidget);
    });

    testWidgets('note list view can be created with category id',
        (tester) async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: NoteListView(
            categoryId: 'category-1',
            noteController: NoteController(firestore: firestore, auth: auth),
            authController: AuthController(auth: auth, firestore: firestore),
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

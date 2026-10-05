import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/controllers/category_controller.dart';
import 'package:notes_management_mobile_application/controllers/note_controller.dart';
import 'package:notes_management_mobile_application/views/categories/add_category_view.dart';
import 'package:notes_management_mobile_application/views/categories/update_category_view.dart';
import 'package:notes_management_mobile_application/views/home/home_view.dart';
import 'package:notes_management_mobile_application/views/notes/add_note_view.dart';
import 'package:notes_management_mobile_application/views/notes/edit_note_view.dart';
import 'package:notes_management_mobile_application/views/notes/note_list_view.dart';

class _TestAuthController extends AuthController {
  _TestAuthController()
      : super(
          auth: MockFirebaseAuth(
            mockUser: MockUser(
              uid: 'owner-user',
              email: 'owner@example.com',
              isEmailVerified: true,
            ),
            signedIn: true,
          ),
          firestore: FakeFirebaseFirestore(),
        );
}

class _TestCategoryController extends CategoryController {
  _TestCategoryController()
      : super(
          auth: MockFirebaseAuth(
            mockUser: MockUser(
              uid: 'owner-user',
              email: 'owner@example.com',
              isEmailVerified: true,
            ),
            signedIn: true,
          ),
          firestore: FakeFirebaseFirestore(),
        );
}

class _TestNoteController extends NoteController {
  _TestNoteController()
      : super(
          auth: MockFirebaseAuth(
            mockUser: MockUser(
              uid: 'owner-user',
              email: 'owner@example.com',
              isEmailVerified: true,
            ),
            signedIn: true,
          ),
          firestore: FakeFirebaseFirestore(),
        );
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    routes: {
      'homepage': (_) => const Scaffold(body: Text('Home')),
      'login': (_) => const Scaffold(body: Text('Login')),
    },
    home: Scaffold(body: child),
  );
}

Future<void> _expectActionAboveKeyboard(
  WidgetTester tester,
  Widget view,
  String action,
) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = const FakeViewPadding(bottom: 300);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);

  await tester.pumpWidget(MaterialApp(home: view));
  await tester.pump();

  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  expect(scaffold.bottomNavigationBar, isNotNull);

  final actionBottom = tester.getRect(find.text(action)).bottom;
  expect(actionBottom, greaterThan(400));
  expect(actionBottom, lessThanOrEqualTo(500));
}

void main() {
  group('Home and CRUD view widgets', () {
    testWidgets('category and note actions stay above the keyboard',
        (tester) async {
      await _expectActionAboveKeyboard(
        tester,
        AddCategoryView(categoryController: _TestCategoryController()),
        'Add',
      );
      await _expectActionAboveKeyboard(
        tester,
        UpdateCategoryView(
          docId: 'cat-1',
          oldName: 'Old category',
          categoryController: _TestCategoryController(),
        ),
        'Save',
      );
      await _expectActionAboveKeyboard(
        tester,
        AddNoteView(
          categoryId: 'category-1',
          noteController: _TestNoteController(),
        ),
        'Add',
      );
      await _expectActionAboveKeyboard(
        tester,
        EditNoteView(
          categoryId: 'category-1',
          noteId: 'note-1',
          oldText: 'Old note',
          noteController: _TestNoteController(),
        ),
        'Save',
      );
    });

    testWidgets('home view renders category header and actions',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          HomeView(
            categoryController: _TestCategoryController(),
            authController: _TestAuthController(),
          ),
        ),
      );

      expect(find.text('List of categories'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('add category view renders form and add button',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          AddCategoryView(categoryController: _TestCategoryController()),
        ),
      );

      expect(find.text('Add Category'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('update category view renders edit title and save button',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          UpdateCategoryView(
            docId: 'cat-1',
            oldName: 'Old category',
            categoryController: _TestCategoryController(),
          ),
        ),
      );

      expect(find.text('Edit Category'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('note list view renders notes screen and add note button',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          NoteListView(
            categoryId: 'category-1',
            noteController: _TestNoteController(),
            authController: _TestAuthController(),
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Add Note'), findsOneWidget);
    });

    testWidgets('add note view renders note form and add button',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          AddNoteView(
            categoryId: 'category-1',
            noteController: _TestNoteController(),
          ),
        ),
      );

      expect(find.text('Add Note'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('edit note view renders edit form and save button',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          EditNoteView(
            categoryId: 'category-1',
            noteId: 'note-1',
            oldText: 'Old note',
            noteController: _TestNoteController(),
          ),
        ),
      );

      expect(find.text('Edit Note'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}

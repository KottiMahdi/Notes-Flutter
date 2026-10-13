import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/auth_controller.dart';
import 'package:notes_management_mobile_application/controllers/category_controller.dart';
import 'package:notes_management_mobile_application/controllers/note_controller.dart';
import 'package:notes_management_mobile_application/models/category_model.dart';
import 'package:notes_management_mobile_application/views/categories/add_category_view.dart';
import 'package:notes_management_mobile_application/views/categories/update_category_view.dart';
import 'package:notes_management_mobile_application/views/home/home_view.dart';
import 'package:notes_management_mobile_application/views/notes/add_note_view.dart';
import 'package:notes_management_mobile_application/views/notes/edit_note_view.dart';
import 'package:notes_management_mobile_application/views/notes/note_list_view.dart';
import 'package:notes_management_mobile_application/views/settings/settings_view.dart';

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

class _FilteringCategoryController extends _TestCategoryController {
  final List<CategoryModel> categories;

  _FilteringCategoryController(this.categories);

  @override
  Future<List<CategoryModel>> getCategories() async => categories;

  @override
  Future<int> getNoteCount(String categoryId) async => 0;
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

void main() {
  group('Home and CRUD view widgets', () {
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

      expect(find.text('All Categories'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('category filters show matching types and All restores them',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          HomeView(
            categoryController: _FilteringCategoryController([
              const CategoryModel(
                id: 'work-1',
                name: 'Office folder',
                userId: 'owner-user',
                type: 'work',
              ),
              const CategoryModel(
                id: 'academic-1',
                name: 'Study folder',
                userId: 'owner-user',
                type: 'Academic',
              ),
              const CategoryModel(
                id: 'personal-1',
                name: 'Home folder',
                userId: 'owner-user',
                type: 'Personal',
              ),
            ]),
            authController: _TestAuthController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Office folder'), findsOneWidget);
      expect(find.text('Study folder'), findsOneWidget);
      expect(find.text('Home folder'), findsOneWidget);

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();
      expect(find.text('Office folder'), findsOneWidget);
      expect(find.text('Study folder'), findsNothing);
      expect(find.text('Home folder'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Office folder'), findsOneWidget);
      expect(find.text('Study folder'), findsOneWidget);
      expect(find.text('Home folder'), findsOneWidget);
    });

    testWidgets('home app bar fits a narrow screen without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapWithApp(
          HomeView(
            categoryController: _TestCategoryController(),
            authController: _TestAuthController(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
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
      expect(find.byTooltip('Add note'), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsNothing);
    });

    testWidgets('all notes add button opens editor and saves to Uncategorized',
        (tester) async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      await tester.pumpWidget(
        _wrapWithApp(
          NoteListView(
            noteController: NoteController(firestore: firestore, auth: auth),
            categoryController:
                CategoryController(firestore: firestore, auth: auth),
            authController: AuthController(auth: auth, firestore: firestore),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add note'));
      await tester.pumpAndSettle();
      expect(find.text('Add a note'), findsNothing);

      final categories = await firestore.collection('categories').get();
      expect(categories.docs, hasLength(1));
      expect(categories.docs.single.data()['name'], 'Uncategorized');
      expect(find.byTooltip('Save'), findsOneWidget);
    });

    testWidgets('all notes groups uncategorized notes in their own section',
        (tester) async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      await firestore.collection('categories').doc('uncategorized').set({
        'name': 'Uncategorized',
        'userId': 'owner-user',
      });
      await firestore
          .collection('categories')
          .doc('uncategorized')
          .collection('note')
          .add({
        'note': 'An uncategorized idea',
        'userId': 'owner-user',
      });
      await firestore.collection('categories').doc('work').set({
        'name': 'Work',
        'userId': 'owner-user',
      });
      await firestore
          .collection('categories')
          .doc('work')
          .collection('note')
          .add({
        'note': 'A work task',
        'userId': 'owner-user',
      });

      await tester.pumpWidget(
        _wrapWithApp(
          NoteListView(
            noteController: NoteController(firestore: firestore, auth: auth),
            categoryController:
                CategoryController(firestore: firestore, auth: auth),
            authController: AuthController(auth: auth, firestore: firestore),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Uncategorized'), findsWidgets);
      expect(find.text('An uncategorized idea'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('In categories'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('In categories'), findsOneWidget);
      expect(find.text('A work task'), findsOneWidget);
    });

    testWidgets('settings view uses the notes icon without a back button',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          SettingsView(
            authController: _TestAuthController(),
            onTabSelected: (_, __) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(
        tester.widget<AppBar>(find.byType(AppBar)).automaticallyImplyLeading,
        isFalse,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.sticky_note_2_outlined),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.settings_outlined),
        ),
        findsNothing,
      );
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('account actions show confirmation dialogs', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          SettingsView(
            authController: _TestAuthController(),
            onTabSelected: (_, __) {},
          ),
        ),
      );

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byIcon(Icons.logout_rounded),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete account?'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byIcon(Icons.delete_outline),
        ),
        findsOneWidget,
      );
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

      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byType(QuillEditor), findsOneWidget);
      expect(find.byTooltip('Bold'), findsOneWidget);
      expect(find.byTooltip('Save'), findsOneWidget);
    });

    testWidgets('edit note view renders heading and note fields, auto-saves',
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

      expect(find.text('Note Editor'), findsNothing);
      expect(find.byIcon(Icons.undo), findsOneWidget);
      expect(find.byIcon(Icons.redo), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(QuillEditor), findsOneWidget);
      expect(find.byTooltip('Bold'), findsOneWidget);
      expect(find.byTooltip('Italic'), findsOneWidget);
      expect(find.byTooltip('Bulleted list'), findsOneWidget);
      expect(find.byTooltip('Numbered list'), findsOneWidget);
      expect(find.byTooltip('Quote'), findsOneWidget);
      expect(find.byTooltip('Checklist'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      final saveButton = find.widgetWithIcon(IconButton, Icons.check);
      expect(tester.widget<IconButton>(saveButton).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'New heading');
      await tester.pump();
      expect(tester.widget<IconButton>(saveButton).onPressed, isNotNull);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
